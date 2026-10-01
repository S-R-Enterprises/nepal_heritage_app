import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The icon set used by the design.
///
/// The Figma export draws every glyph as an inline 24x24 Feather-style SVG.
/// Flutter's Material icon font has no exact match for most of these, so the
/// original path data is reproduced here as [Path] commands in viewbox space
/// and painted at whatever pixel size the caller asks for.
enum AppIcon {
  chevronLeft,
  chevronRight,
  star,
  mapPin,
  check,
  qr,
  cloud,
  shield,
  calendar,
  compass,
  ticket,
  user,
  gem,
  home,
  upload,
  plus,
  minus,
  sun,
  search,
  heart,
}

class AppIconView extends StatelessWidget {
  const AppIconView(
    this.icon, {
    super.key,
    this.size = 18,
    this.color,
    this.strokeWidth = 2,
    this.semanticLabel,
  });

  final AppIcon icon;
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppIconPainter(
          icon: icon,
          color: color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF1E2B18),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  const _AppIconPainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  final AppIcon icon;
  final Color color;
  final double strokeWidth;

  static const double _viewbox = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / _viewbox;
    canvas.save();
    canvas.scale(scale);

    final bool filled = icon == AppIcon.star || icon == AppIcon.shield;
    final Paint paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Helper closures operating in 24x24 viewbox space.
    void polyline(List<Offset> points, {bool close = false}) {
      final Path p = Path()..moveTo(points.first.dx, points.first.dy);
      for (final Offset pt in points.skip(1)) {
        p.lineTo(pt.dx, pt.dy);
      }
      if (close) {
        p.close();
      }
      canvas.drawPath(p, paint);
    }

    void line(Offset a, Offset b) => polyline(<Offset>[a, b]);

    void circle(Offset c, double r) {
      canvas.drawCircle(
        Offset(c.dx * scale, c.dy * scale),
        r * scale,
        paint,
      );
    }

    void rect(double l, double t, double w, double h) {
      canvas.drawRect(Rect.fromLTWH(l, t, w, h), paint);
    }

    switch (icon) {
      case AppIcon.chevronLeft:
        polyline(const <Offset>[Offset(15, 18), Offset(9, 12), Offset(15, 6)]);
      case AppIcon.chevronRight:
        polyline(const <Offset>[Offset(9, 18), Offset(15, 12), Offset(9, 6)]);
      case AppIcon.star:
        polyline(const <Offset>[
          Offset(12, 2),
          Offset(15.09, 8.26),
          Offset(22, 9.27),
          Offset(17, 14.14),
          Offset(18.18, 21.02),
          Offset(12, 17.77),
          Offset(5.82, 21.02),
          Offset(7, 14.14),
          Offset(2, 9.27),
          Offset(8.91, 8.26),
        ], close: true);
      case AppIcon.mapPin:
        final Path p = Path()
          ..moveTo(21, 10)
          // c 0 7 -9 13 -9 13
          ..cubicTo(21, 17, 12, 23, 12, 23)
          // s -9 -6 -9 -13  (c1 mirrors the previous c2, which lands on the
          // current point, so c1 == (12, 23))
          ..cubicTo(12, 23, 3, 17, 3, 10)
          // a 9 9 0 0 1 18 0
          ..arcToPoint(const Offset(21, 10), radius: const Radius.circular(9))
          ..close();
        canvas.drawPath(p, paint);
        circle(const Offset(12, 10), 3);
      case AppIcon.check:
        polyline(const <Offset>[Offset(20, 6), Offset(9, 17), Offset(4, 12)]);
      case AppIcon.qr:
        rect(3, 3, 7, 7);
        rect(14, 3, 7, 7);
        rect(3, 14, 7, 7);
        polyline(const <Offset>[Offset(21, 14), Offset(18, 14), Offset(18, 17), Offset(21, 17)], close: true);
        polyline(const <Offset>[Offset(18, 17), Offset(17, 17), Offset(17, 20), Offset(20, 20), Offset(20, 19)]);
        line(const Offset(14, 17), const Offset(15, 18));
        polyline(const <Offset>[Offset(14, 14), Offset(17, 14), Offset(17, 17), Offset(16, 17)]);
      case AppIcon.cloud:
        final Path p = Path()
          ..moveTo(18, 10)
          ..lineTo(16.74, 10)
          ..arcToPoint(const Offset(9, 20), radius: const Radius.circular(8), clockwise: false)
          ..lineTo(18, 20)
          ..arcToPoint(const Offset(18, 10), radius: const Radius.circular(5), clockwise: false)
          ..close();
        canvas.drawPath(p, paint);
      case AppIcon.shield:
        final Path p = Path()
          ..moveTo(12, 22)
          // s 8 -4 8 -10
          ..cubicTo(20, 18, 20, 12, 20, 12)
          ..lineTo(20, 5)
          ..lineTo(12, 2)
          ..lineTo(4, 5)
          ..lineTo(4, 12)
          ..cubicTo(4, 18, 12, 22, 12, 22)
          ..close();
        canvas.drawPath(p, paint);
      case AppIcon.calendar:
        final Path p = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4, 18, 18), const Radius.circular(2)));
        canvas.drawPath(p, paint);
        line(const Offset(16, 2), const Offset(16, 6));
        line(const Offset(8, 2), const Offset(8, 6));
        line(const Offset(3, 10), const Offset(21, 10));
      case AppIcon.compass:
        circle(const Offset(12, 12), 10);
        polyline(const <Offset>[
          Offset(16.24, 7.76),
          Offset(14.12, 14.12),
          Offset(7.76, 16.24),
          Offset(9.88, 9.88),
        ], close: true);
      case AppIcon.ticket:
        final Path p = Path()
          ..moveTo(2, 9)
          ..arcToPoint(const Offset(2, 15), radius: const Radius.circular(3))
          ..lineTo(2, 17)
          ..arcToPoint(const Offset(4, 19), radius: const Radius.circular(2), clockwise: false)
          ..lineTo(20, 19)
          ..arcToPoint(const Offset(22, 17), radius: const Radius.circular(2), clockwise: false)
          ..lineTo(22, 15)
          ..arcToPoint(const Offset(22, 9), radius: const Radius.circular(3))
          ..lineTo(22, 7)
          ..arcToPoint(const Offset(20, 5), radius: const Radius.circular(2), clockwise: false)
          ..lineTo(4, 5)
          ..arcToPoint(const Offset(2, 7), radius: const Radius.circular(2), clockwise: false)
          ..close();
        canvas.drawPath(p, paint);
        line(const Offset(13, 5), const Offset(13, 7));
        line(const Offset(13, 17), const Offset(13, 19));
        line(const Offset(13, 11), const Offset(13, 13));
      case AppIcon.user:
        final Path p = Path()
          ..moveTo(20, 21)
          ..lineTo(20, 19)
          ..arcToPoint(const Offset(16, 15), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(8, 15)
          ..arcToPoint(const Offset(4, 19), radius: const Radius.circular(4), clockwise: false)
          ..lineTo(4, 21);
        canvas.drawPath(p, paint);
        circle(const Offset(12, 7), 4);
      case AppIcon.gem:
        polyline(const <Offset>[
          Offset(6, 3),
          Offset(18, 3),
          Offset(22, 9),
          Offset(12, 22),
          Offset(2, 9),
        ], close: true);
        line(const Offset(12, 22), const Offset(12, 9));
        polyline(const <Offset>[Offset(2, 9), Offset(12, 9), Offset(22, 9)]);
      case AppIcon.home:
        final Path p = Path()
          ..moveTo(3, 9)
          ..lineTo(12, 2)
          ..lineTo(21, 9)
          ..lineTo(21, 20)
          ..arcToPoint(const Offset(19, 22), radius: const Radius.circular(2))
          ..lineTo(5, 22)
          ..arcToPoint(const Offset(3, 20), radius: const Radius.circular(2))
          ..close();
        canvas.drawPath(p, paint);
        polyline(const <Offset>[Offset(9, 22), Offset(9, 12), Offset(15, 12), Offset(15, 22)]);
      case AppIcon.upload:
        final Path p = Path()
          ..moveTo(21, 15)
          ..lineTo(21, 19)
          ..arcToPoint(const Offset(19, 21), radius: const Radius.circular(2))
          ..lineTo(5, 21)
          ..arcToPoint(const Offset(3, 19), radius: const Radius.circular(2))
          ..lineTo(3, 15);
        canvas.drawPath(p, paint);
        polyline(const <Offset>[Offset(17, 8), Offset(12, 3), Offset(7, 8)]);
        line(const Offset(12, 3), const Offset(12, 15));
      case AppIcon.plus:
        line(const Offset(12, 5), const Offset(12, 19));
        line(const Offset(5, 12), const Offset(19, 12));
      case AppIcon.minus:
        line(const Offset(5, 12), const Offset(19, 12));
      case AppIcon.sun:
        circle(const Offset(12, 12), 5);
        line(const Offset(12, 1), const Offset(12, 3));
        line(const Offset(12, 21), const Offset(12, 23));
        line(const Offset(4.22, 4.22), const Offset(5.64, 5.64));
        line(const Offset(18.36, 18.36), const Offset(19.78, 19.78));
        line(const Offset(1, 12), const Offset(3, 12));
        line(const Offset(21, 12), const Offset(23, 12));
        line(const Offset(4.22, 19.78), const Offset(5.64, 18.36));
        line(const Offset(18.36, 5.64), const Offset(19.78, 4.22));
      case AppIcon.search:
        circle(const Offset(11, 11), 8);
        line(const Offset(21, 21), const Offset(16.65, 16.65));
      case AppIcon.heart:
        final Path p = Path()
          ..moveTo(20.84, 4.61)
          ..arcToPoint(const Offset(13.06, 4.61), radius: const Radius.circular(5.5), clockwise: false)
          ..lineTo(12, 5.67)
          ..lineTo(10.94, 4.61)
          ..arcToPoint(const Offset(3.16, 12.39), radius: const Radius.circular(5.5), clockwise: false)
          ..lineTo(4.22, 13.45)
          ..lineTo(12, 21.23)
          ..lineTo(19.78, 13.45)
          ..lineTo(20.84, 12.39)
          ..arcToPoint(const Offset(20.84, 4.61), radius: const Radius.circular(5.5), clockwise: false)
          ..close();
        canvas.drawPath(p, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter oldDelegate) =>
      oldDelegate.icon != icon ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;

  @override
  bool shouldRebuildSemantics(_AppIconPainter oldDelegate) => false;
}

/// Static QR matrix from the design, reproduced verbatim from `QRCode()` in
/// `App.tsx`. Row-major, 21x21.
const List<List<int>> kQrMatrix = <List<int>>[
  <int>[1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
  <int>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
  <int>[1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1],
  <int>[1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
  <int>[1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1],
  <int>[1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
  <int>[1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
  <int>[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0],
  <int>[1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0],
  <int>[0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1],
  <int>[1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1],
  <int>[0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0],
  <int>[1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1],
  <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0],
  <int>[1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1],
  <int>[1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0],
  <int>[1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1],
  <int>[1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0],
  <int>[1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1],
  <int>[1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
  <int>[1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1],
];

class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, this.color = const Color(0xFF1E2B18)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _QrPainter(color),
      size: Size.infinite,
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final int rows = kQrMatrix.length;
    final int cols = kQrMatrix.first.length;
    // The SVG draws 1.05x1.05 rects on a 1x1 grid to leave a hairline gap.
    final double cell = math.min(size.width / cols, size.height / rows) * 1.05;
    final Paint paint = Paint()..color = color;
    for (int r = 0; r < rows; r++) {
      final List<int> row = kQrMatrix[r];
      for (int c = 0; c < cols; c++) {
        if (row[c] == 0) {
          continue;
        }
        canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.color != color;
}
