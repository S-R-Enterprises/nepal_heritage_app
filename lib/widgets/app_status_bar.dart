import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import '../theme/app_theme.dart';

/// Sets the OS status-bar icon brightness for the screen it sits in, and — when
/// [AppConfig.showMockStatusBar] is enabled — draws the prototype's fake
/// iOS status bar.
///
/// Screens place this inside a `SafeArea` within their coloured header so the
/// header colour still runs all the way to the top of the display.
class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key, this.light = false});

  /// True when the surrounding background is dark and needs light icons.
  final bool light;

  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle style = light
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: AppConfig.showMockStatusBar
          ? _MockStatusBar(color: light ? AppColors.white : AppColors.charcoal)
          : const SizedBox(width: double.infinity),
    );
  }
}

class _MockStatusBar extends StatelessWidget {
  const _MockStatusBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '9:41',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Row(
            children: <Widget>[
              _SignalBars(color: color),
              const SizedBox(width: 6),
              _WifiGlyph(color: color),
              const SizedBox(width: 6),
              _BatteryGlyph(color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const List<double> heights = <double>[7, 9, 11, 12, 10];
    const List<double> opacities = <double>[1, 1, 1, 0.35, 0.2];
    return SizedBox(
      width: 16,
      height: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int i = 0; i < heights.length; i++)
            Container(
              width: 2.5,
              height: heights[i],
              margin: const EdgeInsets.only(right: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacities[i]),
                borderRadius: BorderRadius.circular(0.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _WifiGlyph extends StatelessWidget {
  const _WifiGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 12,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          CustomPaint(
            size: const Size(15, 12),
            painter: _WifiPainter(color),
          ),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _WifiPainter extends CustomPainter {
  const _WifiPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final double w = size.width;
    final double h = size.height;
    // Two arcs, matching the two `path` elements in the prototype's wifi glyph.
    canvas.drawArc(
      Rect.fromLTWH(w * 0.08, h * 0.15, w * 0.84, h * 0.95),
      3.4,
      2.7,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.6, h * 0.72),
      3.4,
      2.7,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_WifiPainter oldDelegate) => oldDelegate.color != color;
}

class _BatteryGlyph extends StatelessWidget {
  const _BatteryGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(1.5, 1.5, 1.5, 1.5),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 18,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 2,
            height: 5,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
