import 'package:flutter/material.dart';

import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';
import 'app_status_bar.dart';
import 'buttons.dart';

/// The five-item bottom navigation bar.
class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    required this.active,
    required this.onChange,
    super.key,
  });

  final AppTab active;
  final ValueChanged<AppTab> onChange;

  static const Map<AppTab, AppIcon> _icons = <AppTab, AppIcon>{
    AppTab.home: AppIcon.home,
    AppTab.gems: AppIcon.gem,
    AppTab.calendar: AppIcon.calendar,
    AppTab.tickets: AppIcon.ticket,
    AppTab.profile: AppIcon.user,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.parchment)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              for (final AppTab tab in AppTab.values)
                _TabItem(
                  tab: tab,
                  icon: _icons[tab]!,
                  isActive: tab == active,
                  onTap: () => onChange(tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final AppTab tab;
  final AppIcon icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.forest : AppColors.tabInactive;

    return Semantics(
      button: true,
      selected: isActive,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // The prototype nudges the active icon up 8% for emphasis.
              AnimatedScale(
                scale: isActive ? 1.08 : 1,
                duration: const Duration(milliseconds: 150),
                child: AppIconView(icon, size: 18, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
              // Reserve the indicator's height in both states so the bar
              // doesn't shift when the selection changes.
              SizedBox(
                height: 4,
                child: isActive
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 4, height: 4),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sticky footer holding a screen's main call-to-action.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.child, super.key, this.gap = 10});

  final Widget child;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.parchment)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Coloured header used by the booking, wallet, gems, calendar and guide
/// screens: an optional back button with a title and subtitle underneath.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.background = AppColors.forest,
    this.onBack,
    this.trailing,
    this.bottomPadding = 20,
  });

  final String title;
  final String? subtitle;
  final Color background;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const AppStatusBar(light: true),
              if (onBack != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: <Widget>[
                      AppBackButton(light: true, onPressed: onBack!),
                      const SizedBox(width: 12),
                      Expanded(child: _titles(context)),
                      ?trailing,
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: _titles(context)),
        if (trailing != null) ...<Widget>[
                          const SizedBox(width: 12),
                          trailing!,
                        ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titles(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.serif,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.2,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12.5,
              color: Color(0xA6FFFFFF),
            ),
          ),
      ],
    );
  }
}
