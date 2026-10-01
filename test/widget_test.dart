import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/app.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/onboarding_screen.dart';
import 'package:nepal_np/theme/app_theme.dart';
import 'package:nepal_np/widgets/bottom_tab_bar.dart';

void main() {
  testWidgets('onboarding shows the first slide and enters the app on continue',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NepalHeritageApp());

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

    expect(router.screen, AppScreen.onboarding);
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

  test('palette matches the design tokens', () {
    expect(AppColors.forest, const Color(0xFF2C5F2D));
    expect(AppColors.gold, const Color(0xFFC9A227));
    expect(AppColors.cream, const Color(0xFFF5F1E6));
    expect(AppColors.charcoal, const Color(0xFF1E2B18));
  });
}
