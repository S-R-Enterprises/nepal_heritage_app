import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/app.dart';
import 'package:nepal_np/data/chat_service.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/chatbot_screen.dart';
import 'package:nepal_np/screens/home_screen.dart';
import 'package:nepal_np/screens/landing_screen.dart';
import 'package:nepal_np/screens/login_screen.dart';
import 'package:nepal_np/screens/onboarding_screen.dart';
import 'package:nepal_np/screens/register_screen.dart';
import 'package:nepal_np/theme/app_theme.dart';
import 'package:nepal_np/widgets/bottom_tab_bar.dart';

/// The tests that drive the whole app shell render fixed-width cards, and the
/// wide fallback test font is just wide enough to overflow them. Load the
/// bundled families so these tests measure the same metrics the app ships with,
/// as `screens_test.dart` and `auth_flow_test.dart` already do.
Future<void> loadRealFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Lora': <String>['Lora-400normal.ttf', 'Lora-600normal.ttf', 'Lora-700normal.ttf'],
    'DMSans': <String>['DMSans-400normal.ttf', 'DMSans-500normal.ttf', 'DMSans-600normal.ttf'],
  };

  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String file in family.value) {
      loader.addFont(
        Future<ByteData>.value(
          ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }
}

void main() {
  setUpAll(loadRealFonts);
  testWidgets('landing routes to registration and login', (WidgetTester tester) async {
    await tester.pumpWidget(const NepalHeritageApp());

    // The app opens on the marketing screen, with the tab bar suppressed.
    expect(find.byType(LandingScreen), findsOneWidget);
    expect(find.byType(BottomTabBar), findsNothing);
    expect(find.text('Namaste · Welcome'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // The top-right Register pill opens the sign-up form.
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    // ...and back out again through its back chevron.
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(LandingScreen), findsOneWidget);

    // The Login pill opens the sign-in form.
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);

    // Get Started lands on sign-in too, so a first-time visitor always passes
    // through the login page rather than straight into the long sign-up form.
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('the home chat button opens the assistant', (WidgetTester tester) async {
    // Phone-sized, matching the other suites: the assistant takes the height the
    // tab bar gives up, which lays out one more home card.
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const NepalHeritageApp());

    // Reach the app the way onboarding would.
    final AppRouterScope scope = tester
        .element(find.byType(LandingScreen))
        .dependOnInheritedWidgetOfExactType<AppRouterScope>()!;
    scope.notifier!.start();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ChatFabButton));
    // Not pumpAndSettle: the assistant's presence dot pulses forever, so there is
    // no settled frame to wait for.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ChatbotScreen), findsOneWidget);
    expect(find.text('Nepal Assistant'), findsOneWidget);
    expect(find.textContaining('Namaste'), findsOneWidget);
    // The thread takes the whole screen, so the tab bar steps aside.
    expect(find.byType(BottomTabBar), findsNothing);

    // A starter prompt is sent as-is and answered after the round-trip delay.
    await tester.tap(find.text('What is on this month?'));
    await tester.pump();
    expect(find.text('Namaste! I am your Nepal heritage guide.'), findsNothing);

    await tester.pump(ChatService.latency + const Duration(milliseconds: 50));
    expect(find.textContaining('Indra Jatra is next'), findsOneWidget);

    // The follow-up links hand the traveller over to the screen that does the work.
    await tester.tap(find.text('See the calendar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(scope.notifier!.screen, AppScreen.calendar);
  });

  testWidgets('onboarding shows the first slide and enters the app on continue',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NepalHeritageApp());

    // Reach onboarding through the router, since the app now opens on /landing.
    final AppRouterScope scope = tester
        .element(find.byType(LandingScreen))
        .dependOnInheritedWidgetOfExactType<AppRouterScope>()!;
    scope.notifier!.go(AppScreen.onboarding);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text("Discover Nepal's Living Heritage"), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next \u2192'), findsOneWidget);
    // The tab bar is suppressed during onboarding.
    expect(find.byType(BottomTabBar), findsNothing);

    await tester.tap(find.text('Next \u2192'));
    await tester.pumpAndSettle();
    expect(find.text('Plan Around Festivals'), findsOneWidget);

    await tester.tap(find.text('Next \u2192'));
    await tester.pumpAndSettle();
    expect(find.text('Explore Nepal \u2192'), findsOneWidget);

    await tester.tap(find.text('Explore Nepal \u2192'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomTabBar), findsOneWidget);
  });

  test('router pushes, pops and maps tabs to screens', () {
    final AppRouter router = AppRouter();

    // The app opens on the landing screen, which has no tab bar.
    expect(router.screen, AppScreen.landing);
    expect(router.showTabs, isFalse);

    router.start();
    expect(router.screen, AppScreen.home);
    expect(router.showTabs, isTrue);

    router.go(AppScreen.heritageDetail);
    expect(router.screen, AppScreen.heritageDetail);
    expect(router.canPop, isTrue);

    expect(router.pop(), isTrue);
    expect(router.screen, AppScreen.home);

    router.switchTab(AppTab.calendar);
    expect(router.screen, AppScreen.calendar);
    expect(router.activeTab, AppTab.calendar);
    expect(router.canPop, isFalse);
  });

  test('the auth screens hide the tab bar, and replaceWith clears the stack', () {
    final AppRouter router = AppRouter();

    router.go(AppScreen.register);
    expect(router.screen, AppScreen.register);
    expect(router.showTabs, isFalse);
    // Landing stays underneath, so the back gesture returns there.
    expect(router.canPop, isTrue);
    expect(router.pop(), isTrue);
    expect(router.screen, AppScreen.landing);

    router.go(AppScreen.login);
    expect(router.screen, AppScreen.login);
    expect(router.showTabs, isFalse);

    // A successful sign-in must not leave the form on the back stack.
    router.replaceWith(AppScreen.home);
    expect(router.screen, AppScreen.home);
    expect(router.canPop, isFalse);
    expect(router.showTabs, isTrue);
  });

  test('palette matches the design tokens', () {
    expect(AppColors.forest, const Color(0xFF2C5F2D));
    expect(AppColors.gold, const Color(0xFFC9A227));
    expect(AppColors.cream, const Color(0xFFF5F1E6));
    expect(AppColors.charcoal, const Color(0xFF1E2B18));
  });
}
