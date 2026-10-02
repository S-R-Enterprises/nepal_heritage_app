import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';

/// A translucent, blurred surface for controls that sit on top of a photograph.
///
/// The fill is a semi-transparent charcoal rather than a solid colour, so a pill
/// stays legible over a bright sky or a dark temple stone without the screen
/// needing a second opaque layer behind it.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    this.borderRadius,
    this.opacity = 0.45,
    this.blur = 12,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double opacity;
  final double blur;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(AppRadii.pill);
    final bool tappable = onTap != null;

    return Semantics(
      label: semanticLabel,
      button: tappable,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: AppColors.charcoal.withValues(alpha: opacity),
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: borderColor == null
                      ? null
                      : Border.all(color: borderColor!, width: borderWidth),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded pill with an icon and a label, the standard control on the landing
/// screen's photo background.
class GlassPill extends StatelessWidget {
  const GlassPill({
    required this.label,
    super.key,
    this.icon,
    this.iconColor = AppColors.white,
    this.labelColor = AppColors.white,
    this.onTap,
    this.opacity = 0.45,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.borderColor,
    this.semanticLabel,
  });

  final String label;
  final AppIcon? icon;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback? onTap;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      onTap: onTap,
      opacity: opacity,
      padding: padding,
      borderColor: borderColor,
      semanticLabel: semanticLabel ?? label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            AppIconView(icon!, size: 15, color: iconColor),
            const SizedBox(width: 6),
          ],
          // Flexible so a label truncates rather than overflowing if the pill
          // is ever placed in a constrained box.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The app emblem: a frosted rounded square holding a dark green disc with a
/// gold ring and a gold pagoda.
///
/// [size] drives the whole lockup, so the 70px landing version and the 56px
/// login version are the same widget at two sizes.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key, this.size = 70});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        // ~20px corner radius at the default size.
        borderRadius: BorderRadius.circular(size * 0.28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.28),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(size * 0.28),
            ),
            child: Center(
              child: Container(
                width: size * 0.66,
                height: size * 0.66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.forest,
                  border: Border.all(
                    color: AppColors.gold,
                    width: size * 0.028,
                  ),
                ),
                child: Center(
                  child: AppIconView(
                    AppIcon.pagoda,
                    size: size * 0.4,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width primary action in the forest green used by the form screens.
///
/// Supports a loading state and a disabled state; the disabled fill is a
/// desaturated forest rather than grey so the button still reads as part of the
/// palette.
class SolidActionButton extends StatelessWidget {
  const SolidActionButton({
    required this.label,
    super.key,
    this.onPressed,
    this.loading = false,
    this.height = 52,
    this.background = AppColors.forest,
    this.foreground = AppColors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !loading;
    final Color fill = enabled ? background : background.withValues(alpha: 0.35);
    final Color text = enabled ? foreground : foreground.withValues(alpha: 0.85);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(text),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The decorative home-indicator bar drawn inside the landing screen's bottom
/// safe-area strip, matching the native gesture bar.
class HomeIndicatorBar extends StatelessWidget {
  const HomeIndicatorBar({super.key, this.width = 120, this.color = AppColors.moss});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
