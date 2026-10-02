import 'package:flutter/widgets.dart';

import '../data/language_data.dart';

/// Holds the app's display language and notifies listeners when it changes.
///
/// Only the landing screen's selector writes to it today, but the scope is
/// lifted above `MaterialApp` so any screen can read the current language and so
/// wiring real `flutter_localizations` delegates later is a one-line change.
class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController() : super(DisplayLanguages.english.locale);

  static final AppLocaleController global = AppLocaleController();

  /// The currently selected language.
  DisplayLanguage get language {
    for (final DisplayLanguage l in DisplayLanguages.all) {
      if (l.locale.languageCode == value.languageCode) {
        return l;
      }
    }
    return DisplayLanguages.english;
  }

  void select(DisplayLanguage language) => value = language.locale;
}

/// Exposes [AppLocaleController] to descendant widgets.
class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    required AppLocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppLocaleController of(BuildContext context) {
    final AppLocaleScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'No AppLocaleScope found in context');
    return scope!.notifier!;
  }

  /// Read without subscribing — for callbacks.
  static AppLocaleController read(BuildContext context) {
    final AppLocaleScope? scope =
        context.getInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'No AppLocaleScope found in context');
    return scope!.notifier!;
  }
}
