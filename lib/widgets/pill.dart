import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';

/// Filter chip. Active state fills with forest green, inactive uses parchment.
class Pill extends StatelessWidget {
  const Pill({
    required this.label,
    super.key,
    this.active = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.forest : AppColors.parchment,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: padding,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.white : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold "Verified Gem" pill with a shield glyph.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.label = 'Verified Gem'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AppIconView(AppIcon.shield, size: 14, color: AppColors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "✓ VERIFIED" overlay tag used on gem thumbnails.
class VerifiedTag extends StatelessWidget {
  const VerifiedTag({super.key, this.withIcon = false, this.top = 10, this.left = 10});

  final bool withIcon;
  final double top;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: withIcon ? 10 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (withIcon) ...<Widget>[
            const AppIconView(AppIcon.shield, size: 12, color: AppColors.charcoal),
            const SizedBox(width: 4),
          ],
          const Text(
            'VERIFIED',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark translucent category tag overlaid on gem thumbnails.
class CategoryTag extends StatelessWidget {
  const CategoryTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.charcoal.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 10,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// Gold star plus numeric rating, as used on site and gem cards.
class RatingStars extends StatelessWidget {
  const RatingStars(this.rating, {super.key, this.iconSize = 12, this.fontSize = 12});

  final double rating;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppIconView(AppIcon.star, size: iconSize, color: AppColors.gold),
        const SizedBox(width: 3),
        Text(
          rating.toString(),
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}

/// A row of filled stars, optionally followed by a numeric score.
class StarRow extends StatelessWidget {
  const StarRow({
    required this.count,
    super.key,
    this.size = 12,
    this.color = AppColors.gold,
    this.trailing,
  });

  final int count;
  final double size;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < count; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 2),
          AppIconView(AppIcon.star, size: size, color: color),
        ],
        ?trailing,
      ],
    );
  }
}

/// Muted pin + short location line.
class LocationLine extends StatelessWidget {
  const LocationLine(
    this.label, {
    super.key,
    this.color = AppColors.muted,
    this.fontSize = 11,
  });

  final String label;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppIconView(AppIcon.mapPin, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: fontSize,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
