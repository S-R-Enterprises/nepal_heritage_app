import 'package:flutter/widgets.dart';

/// Every screen in the app. Mirrors the `Screen` union type in `App.tsx`.
enum AppScreen {
  landing,
  register,
  login,
  forgotPassword,
  onboarding,
  home,
  heritageDetail,
  allSites,
  ticketBooking,
  ticketConfirm,
  qrWallet,
  hiddenGems,
  hiddenGemDetail,
  submitGem,
  calendar,
  festivalDetail,
  guideProfile,
  allGuides,
  profile,
  chatbot,
}

/// The five bottom-tab destinations. Mirrors the `Tab` union type in `App.tsx`.
enum AppTab {
  home('Home', AppScreen.home),
  gems('Gems', AppScreen.hiddenGems),
  calendar('Festivals', AppScreen.calendar),
  tickets('Tickets', AppScreen.qrWallet),
  profile('Profile', AppScreen.profile);

  const AppTab(this.label, this.screen);

  final String label;
  final AppScreen screen;
}

/// Simple push/pop stack router.
///
/// The React prototype keeps a manual `history` array and swaps the rendered
/// tree; this reproduces that model while also honouring the platform back
/// button and predictive-back gesture on Android.
///
/// Screens should be rebuilt whenever the router notifies, so a single
/// [AnimatedSwitcher] at the root can cross-fade between them.
class AppRouter extends ChangeNotifier {
  AppScreen _screen = AppScreen.landing;
  final List<AppScreen> _history = <AppScreen>[];
  AppTab _activeTab = AppTab.home;

  AppScreen get screen => _screen;
  AppTab get activeTab => _activeTab;
  bool get canPop => _history.isNotEmpty;

  /// The tab bar is hidden on the entry and auth screens, on onboarding, on
  /// the post-payment confirmation screen, and on the chat thread, matching
  /// `showTabs` in `App.tsx`.
  bool get showTabs =>
      _screen != AppScreen.landing &&
      _screen != AppScreen.register &&
      _screen != AppScreen.login &&
      _screen != AppScreen.forgotPassword &&
      _screen != AppScreen.onboarding &&
      _screen != AppScreen.ticketConfirm &&
      _screen != AppScreen.chatbot;

  /// Push [to] on top of the current screen.
  void go(AppScreen to) {
    _history.add(_screen);
    _screen = to;
    // Any push implies the active tab is whatever tab owns the new screen, so
    // the bar never highlights a tab the user has navigated away from.
    for (final AppTab tab in AppTab.values) {
      if (tab.screen == to) {
        _activeTab = tab;
      }
    }
    notifyListeners();
  }

  /// Pop back to the previous screen. Returns false if there is nothing to pop,
  /// which lets [PopScope] defer to the platform (i.e. exit the app).
  bool pop() {
    if (_history.isEmpty) {
      return false;
    }
    _screen = _history.removeLast();
    _syncTabToScreen();
    notifyListeners();
    return true;
  }

  /// Jump straight to a tab, clearing the back stack.
  void switchTab(AppTab tab) {
    _history.clear();
    _activeTab = tab;
    _screen = tab.screen;
    notifyListeners();
  }

  /// Used by onboarding to enter the app without pushing a history entry.
  void start() {
    _history.clear();
    _screen = AppScreen.home;
    _activeTab = AppTab.home;
    notifyListeners();
  }

  /// Swap the whole stack for [to].
  ///
  /// Used when auth succeeds: landing → login → home should not leave the
  /// back gesture returning the user to the sign-in form they just completed.
  void replaceWith(AppScreen to) {
    _history.clear();
    _screen = to;
    for (final AppTab tab in AppTab.values) {
      if (tab.screen == to) {
        _activeTab = tab;
      }
    }
    notifyListeners();
  }

  void _syncTabToScreen() {
    for (final AppTab tab in AppTab.values) {
      if (tab.screen == _screen) {
        _activeTab = tab;
        return;
      }
    }
  }
}

/// Exposes the nearest [AppRouter] to descendant screens.
class AppRouterScope extends InheritedNotifier<AppRouter> {
  const AppRouterScope({
    required AppRouter router,
    required super.child,
    super.key,
  }) : super(notifier: router);

  static AppRouter of(BuildContext context) {
    final AppRouterScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppRouterScope>();
    assert(scope != null, 'No AppRouterScope found in context');
    return scope!.notifier!;
  }

  /// Convenience for `AppRouterScope.of(context).go(...)` in callbacks.
  static void go(BuildContext context, AppScreen to) =>
      of(context).go(to);

  static void back(BuildContext context) => of(context).pop();
}
