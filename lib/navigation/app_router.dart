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
  Object? _arg;
  final List<(AppScreen, Object?)> _history = <(AppScreen, Object?)>[];
  AppTab _activeTab = AppTab.home;

  AppScreen get screen => _screen;

  /// The payload passed to the current screen by the navigation that opened
  /// it — e.g. the tapped [HeritageSite] on `heritageDetail`. Null when the
  /// screen was reached without one (tabs, auth flows, direct jumps).
  Object? get arg => _arg;

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

  /// Push [to] on top of the current screen, optionally carrying [arg] as the
  /// destination's payload (read back via [arg]). A push always replaces the
  /// current payload — going somewhere without an arg clears it, so screens
  /// never see a stale item.
  void go(AppScreen to, {Object? arg}) {
    _history.add((_screen, _arg));
    _screen = to;
    _arg = arg;
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
    final (AppScreen screen, Object? arg) = _history.removeLast();
    _screen = screen;
    _arg = arg;
    _syncTabToScreen();
    notifyListeners();
    return true;
  }

  /// Jump straight to a tab, clearing the back stack.
  void switchTab(AppTab tab) {
    _history.clear();
    _activeTab = tab;
    _screen = tab.screen;
    _arg = null;
    notifyListeners();
  }

  /// Used by onboarding to enter the app without pushing a history entry.
  void start() {
    _history.clear();
    _screen = AppScreen.home;
    _activeTab = AppTab.home;
    _arg = null;
    notifyListeners();
  }

  /// Swap the whole stack for [to].
  ///
  /// Used when auth succeeds: landing → login → home should not leave the
  /// back gesture returning the user to the sign-in form they just completed.
  void replaceWith(AppScreen to) {
    _history.clear();
    _screen = to;
    _arg = null;
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
  static void go(BuildContext context, AppScreen to, {Object? arg}) =>
      of(context).go(to, arg: arg);

  static void back(BuildContext context) => of(context).pop();
}
