import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_status_bar.dart';
import '../widgets/buttons.dart';

/// Post-payment confirmation with the scannable ticket QR and booking
/// reference. The tab bar is hidden on this screen.
class TicketConfirmScreen extends StatelessWidget {
  const TicketConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          const AppStatusBar(light: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.09),
                      shape: BoxShape.circle,
                    ),
                    child: const AppIconView(
                      AppIcon.check,
                      size: 40,
                      color: AppColors.forest,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Booking Confirmed!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your entry ticket for ${MockData.heritageTitle} on '
                    '${MockData.confirmDateLabel} is ready. Show QR code at the entrance.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppShadows.floating,
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          width: 160,
                          height: 160,
                          child: QrCodeView(),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.parchment,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Column(
                            children: <Widget>[
                              const Text(
                                'Booking Reference',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                MockData.bookingReference,
                                style: const TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'View in My Tickets',
                    color: AppColors.forest,
                    foregroundColor: AppColors.white,
                    onPressed: () => router.go(AppScreen.qrWallet),
                  ),
                  const SizedBox(height: 12),
                  const _GhostButton(label: 'Back to Home'),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: InkWell(
          onTap: () => AppRouterScope.of(context).switchTab(AppTab.home),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: AppColors.parchment, width: 1.5),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
