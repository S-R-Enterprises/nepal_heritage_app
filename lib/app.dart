import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navigation/app_router.dart';
import 'screens/calendar_screen.dart';
import 'screens/festival_detail_screen.dart';
import 'screens/guide_profile_screen.dart';
import 'screens/heritage_detail_screen.dart';
import 'screens/hidden_gem_detail_screen.dart';
import 'screens/hidden_gems_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_wallet_screen.dart';
import 'screens/submit_gem_screen.dart';
import 'screens/ticket_booking_screen.dart';
import 'screens/ticket_confirm_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_tab_bar.dart';

/// Root widget. Owns the [AppRouter], renders the active screen and, when the
/// active screen wants it, the bottom tab bar.
class NepalHeritageApp extends StatefulWidget {
  const NepalHeritageApp({super.key});

  @override
  State<NepalHeritageApp> createState() => _NepalHeritageAppState();
}

class _NepalHeritageAppState extends State<NepalHeritageApp> {
  final AppRouter _router = AppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppRouterScope(
      router: _router,
      child: MaterialApp(

        title: 'Nepal Heritage',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AppShell(),
        builder: (BuildContext context, Widget? child) {
          // Pin text scaling to a sane range; the design is dense and does not
          // tolerate the 2x system setting without overflowing everywhere.
          final MediaQueryData media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        // Nothing left in our own stack, so defer to the platform and let the
        // activity finish (Android) or the app background (iOS).
        if (!router.pop()) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: Column(
          children: <Widget>[
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey<AppScreen>(router.screen),
                  child: _buildScreen(router.screen),
                ),
              ),
            ),
            if (router.showTabs)
              BottomTabBar(
                active: router.activeTab,
                onChange: router.switchTab,
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildScreen(AppScreen screen) {
    return switch (screen) {
      AppScreen.onboarding => const OnboardingScreen(),
      AppScreen.home => const HomeScreen(),
      AppScreen.heritageDetail => const HeritageDetailScreen(),
      AppScreen.ticketBooking => const TicketBookingScreen(),
      AppScreen.ticketConfirm => const TicketConfirmScreen(),
      AppScreen.qrWallet => const QrWalletScreen(),
      AppScreen.hiddenGems => const HiddenGemsScreen(),
      AppScreen.hiddenGemDetail => const HiddenGemDetailScreen(),
      AppScreen.submitGem => const SubmitGemScreen(),
      AppScreen.calendar => const CalendarScreen(),
      AppScreen.festivalDetail => const FestivalDetailScreen(),
      AppScreen.guideProfile => const GuideProfileScreen(),
      AppScreen.profile => const ProfileScreen(),
    };
  }
}
