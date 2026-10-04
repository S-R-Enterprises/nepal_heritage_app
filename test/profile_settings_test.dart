import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/data/auth_service.dart';
import 'package:nepal_np/navigation/app_locale.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/chatbot_screen.dart';
import 'package:nepal_np/screens/landing_screen.dart';
import 'package:nepal_np/screens/profile_screen.dart';

import 'test_helpers.dart';

/// Profile settings: every row does something, and Sign Out ends the session.
void main() {
  setUpAll(loadRealFonts);

  tearDown(AuthService.instance.signOut);

  Future<void> openProfile(WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.profile);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  }

  Future<void> reveal(WidgetTester tester, String label) async {
    final Finder row = find.text(label);
    await tester.scrollUntilVisible(row, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  testWidgets('language row opens the picker and relabels itself',
      (WidgetTester tester) async {
    await openProfile(tester);
    await reveal(tester, 'Language \u00b7 English');

    await tester.tap(find.text('Language \u00b7 English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('Nepali'));
    await tester.pumpAndSettle();

    expect(find.text('Language \u00b7 Nepali'), findsOneWidget);
    final AppLocaleController locale = AppLocaleScope.of(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(locale.language.englishName, 'Nepali');
  });

  testWidgets('unfinished settings rows show the honest coming-soon sheet',
      (WidgetTester tester) async {
    await openProfile(tester);
    await reveal(tester, 'Notifications');

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('COMING SOON'), findsOneWidget);
    expect(find.text('Notifications'), findsWidgets);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('COMING SOON'), findsNothing);
  });

  testWidgets('help & support opens the assistant', (WidgetTester tester) async {
    await openProfile(tester);
    await reveal(tester, 'Help & Support');

    await tester.tap(find.text('Help & Support'));
    // Not pumpAndSettle: the assistant's presence dot pulses forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ChatbotScreen), findsOneWidget);
  });

  testWidgets('sign out ends the session and returns to landing',
      (WidgetTester tester) async {
    await openProfile(tester);

    final Future<AuthUser> login = AuthService.instance.login(
      identifier: AuthService.demoEmail,
      password: AuthService.demoPassword,
      rememberMe: false,
    );
    await tester.pump(AuthService.latency);
    await login;

    // Rebuild the header with the session before signing out again.
    final AppRouter router = AppRouterScope.of(
      tester.element(find.byType(ProfileScreen)),
    );
    router.switchTab(AppTab.home);
    await tester.pumpAndSettle();
    router.switchTab(AppTab.profile);
    await tester.pumpAndSettle();
    expect(find.text('Demo Visitor'), findsOneWidget);

    await reveal(tester, 'Sign Out');
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(find.byType(LandingScreen), findsOneWidget);
    expect(AuthService.instance.currentUser, isNull);
  });
}
