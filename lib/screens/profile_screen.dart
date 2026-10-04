import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_status_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/coming_soon.dart';
import '../widgets/network_photo.dart';

/// Account screen: identity header, lifetime stats, recent bookings and the
/// settings list.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          const _IdentityHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const _StatsRow(),
                  const SizedBox(height: 20),
                  const _BookingsSection(),
                  const SizedBox(height: 16),
                  const _SettingsSection(),
                  const SizedBox(height: 16),
                  const _GuideCta(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader();

  @override
  Widget build(BuildContext context) {
    // The signed-in account, or the prototype's visitor identity when the
    // screen is reached without a session (tests, direct jumps).
    final AuthUser? user = AuthService.instance.currentUser;
    final String name = user?.fullName ?? MockData.userName;
    final String meta = user?.email ?? MockData.userMeta;

    return Container(
      width: double.infinity,
      color: AppColors.charcoal,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: <Widget>[
              const AppStatusBar(light: true),
              const SizedBox(height: 16),
              const Avatar(
                url: Img.avatarUserLarge,
                size: 72,
                borderColor: AppColors.moss,
                borderWidth: 3,
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: AppFonts.serif,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meta,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < MockData.userStats.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: AppCard(
              radius: AppRadii.lg,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              shadows: const <BoxShadow>[],
              child: Column(
                children: <Widget>[
                  Text(
                    MockData.userStats[i].value,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MockData.userStats[i].label,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BookingsSection extends StatelessWidget {
  const _BookingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardHeading('Recent Bookings', bottom: 0),
        ),
        for (final BookingRecord booking in MockData.recentBookings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              radius: AppRadii.lg,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: NetworkPhoto(url: booking.image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          booking.name,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.type} \u00b7 ${booking.date}',
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: booking.status == 'Upcoming'
                          ? AppColors.forest.withValues(alpha: 0.08)
                          : AppColors.muted.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: booking.status == 'Upcoming'
                            ? AppColors.forest
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < MockData.settingsRows.length; i++) ...<Widget>[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: 54),
                child: Divider(height: 1, color: AppColors.parchment),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Text(
                    MockData.settingsRows[i].icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      MockData.settingsRows[i].label,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const AppIconView(
                    AppIcon.chevronRight,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuideCta extends StatelessWidget {
  const _GuideCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              AppIconView(AppIcon.compass, size: 18, color: AppColors.forest),
              SizedBox(width: 8),
              Text(
                'Share your Nepal',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Know a place tourists should not miss? Submit it as a hidden gem or '
            'apply to become a verified local guide.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              height: 1.5,
              color: AppColors.body,
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Become a Guide',
            color: AppColors.forest,
            foregroundColor: AppColors.white,
            verticalPadding: 12,
            fontSize: 14,
            onPressed: () => showComingSoon(
              context,
              title: 'Become a Guide',
              blurb:
                  'Guide applications open soon. We will verify your identity, '
                  'languages and areas before travelers can book you.',
            ),
          ),
        ],
      ),
    );
  }
}
