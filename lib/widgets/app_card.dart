import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The white rounded panel used for nearly every content block in the design.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadii.xxl,
    this.color = AppColors.white,
    this.border,
    this.shadows,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: shadows ?? AppShadows.card,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

/// Serif section heading with an optional trailing text action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 14),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card sub-heading, e.g. "What to Expect" / "Payment Method".
class CardHeading extends StatelessWidget {
  const CardHeading(this.label, {super.key, this.fontSize = 14, this.bottom = 12});

  final String label;
  final double fontSize;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}

/// Small uppercase label above a form field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Compact label/value tile used in the info rows on the detail screens.
class InfoTileView extends StatelessWidget {
  const InfoTileView({
    required this.label,
    required this.value,
    super.key,
    this.background = AppColors.cream,
    this.valueColor = AppColors.charcoal,
    this.valueSize = 11,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
  });

  final String label;
  final String value;
  final Color background;
  final Color valueColor;
  final double valueSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A row of [InfoTileView]s that share the width evenly.
class InfoTileRow extends StatelessWidget {
  const InfoTileRow({
    required this.tiles,
    super.key,
    this.gap = 10,
    this.background = AppColors.cream,
    this.valueSize = 11,
  });

  final List<({String label, String value})> tiles;
  final double gap;
  final Color background;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: InfoTileView(
              label: tiles[i].label,
              value: tiles[i].value,
              background: background,
              valueSize: valueSize,
            ),
          ),
        ],
      ],
    );
  }
}
