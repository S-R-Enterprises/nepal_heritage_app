import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';

/// Filled call-to-action. Defaults to the design's gold button with charcoal
/// text; pass [color] for the forest / purple variants.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    super.key,
    this.onPressed,
    this.icon,
    this.color = AppColors.gold,
    this.foregroundColor = AppColors.charcoal,
    this.verticalPadding = 16,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppIcon? icon;
  final Color color;
  final Color foregroundColor;
  final double verticalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  AppIconView(icon!, size: 18, color: foregroundColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined action. Designed to sit inside a [Row] — it expands to fill its
/// share of the available width.
class OutlineActionButton extends StatelessWidget {
  const OutlineActionButton({
    required this.label,
    super.key,
    this.onPressed,
    this.borderColor = AppColors.parchment,
    this.foregroundColor = AppColors.charcoal,
    this.backgroundColor = Colors.transparent,
    this.icon,
    this.flex = 1,
    this.borderWidth = 1.5,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final AppIcon? icon;
  final int flex;
  final double borderWidth;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  AppIconView(icon!, size: 18, color: foregroundColor),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular icon button used for back / favourite / stepper controls.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.size = 36,
    this.iconSize = 20,
    this.background = AppColors.parchment,
    this.foreground = AppColors.charcoal,
    this.borderColor,
    this.borderWidth = 0,
  });

  final AppIcon icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: CircleBorder(
        side: borderColor == null
            ? BorderSide.none
            : BorderSide(color: borderColor!, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: AppIconView(icon, size: iconSize, color: foreground)),
        ),
      ),
    );
  }
}

/// Translucent circular control that sits on top of a photo hero.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({required this.icon, super.key, this.onPressed, this.size = 36});

  final AppIcon icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withValues(alpha: 0.2),
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: AppIconView(icon, size: 20, color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular back chevron. [light] is for use over photographic heroes.
class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onPressed, super.key, this.light = false, this.size = 36});

  final VoidCallback onPressed;
  final bool light;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (light) {
      return GlassIconButton(icon: AppIcon.chevronLeft, onPressed: onPressed, size: size);
    }
    return RoundIconButton(
      icon: AppIcon.chevronLeft,
      onPressed: onPressed,
      size: size,
      background: AppColors.parchment,
      foreground: AppColors.charcoal,
    );
  }
}
