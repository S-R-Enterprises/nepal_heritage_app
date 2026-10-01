import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Network image with a parchment placeholder and a fade-in on load, standing in
/// for the raw `<img>` tags in the prototype.
class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.alignment = Alignment.center,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: true,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) {
        if (progress == null) {
          return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 250),
            child: child,
          );
        }
        return const SizedBox.expand(child: ColoredBox(color: AppColors.parchment));
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return const SizedBox.expand(
          child: ColoredBox(
            color: AppColors.parchment,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.muted,
                size: 20,
              ),
            ),
          ),
        );
      },
    );

    if (borderRadius == null) {
      return SizedBox(width: width, height: height, child: image);
    }
    return ClipRRect(
      borderRadius: borderRadius!,
      child: SizedBox(width: width, height: height, child: image),
    );
  }
}

/// Circular avatar helper.
class Avatar extends StatelessWidget {
  const Avatar({
    required this.url,
    super.key,
    this.size = 44,
    this.borderColor = AppColors.parchment,
    this.borderWidth = 2,
  });

  final String url;
  final double size;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}

/// A photo with a vertical scrim on top, used for the detail-screen heroes.
///
/// [gradient] accepts the same colours as the prototype's CSS gradients, e.g.
/// `['rgba(0,0,0,0.3)', 'transparent', 'rgba(30,43,24,0.7)']`.
class PhotoScrim extends StatelessWidget {
  const PhotoScrim({
    required this.url,
    super.key,
    this.height,
    this.gradient,
    this.alignment = Alignment.center,
    this.child,
  });

  final String url;
  final double? height;
  final List<String>? gradient;
  final Alignment alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          NetworkPhoto(url: url, fit: BoxFit.cover, alignment: alignment),
          if (gradient != null)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradient!.map(_parseColor).toList(),
                ),
              ),
            ),
          ?child,
        ],
      ),
    );
  }
}

/// Parses the `#RRGGBB` / `transparent` / `rgba(r,g,b,a)` colour strings used in
/// the prototype's inline styles.
Color _parseColor(String value) {
  final String v = value.trim().toLowerCase();
  if (v == 'transparent') {
    return const Color(0x00000000);
  }
  if (v.startsWith('#')) {
    final String hex = v.substring(1);
    final String expanded = hex.length == 3
        ? hex.split('').map((String c) => '$c$c').join()
        : hex;
    return Color(int.parse('FF$expanded', radix: 16));
  }
  final RegExpMatch? match = RegExp(
    r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)',
  ).firstMatch(v);
  if (match != null) {
    final int r = int.parse(match.group(1)!);
    final int g = int.parse(match.group(2)!);
    final int b = int.parse(match.group(3)!);
    final double a = double.tryParse(match.group(4) ?? '1') ?? 1;
    return Color.fromRGBO(r, g, b, a);
  }
  return const Color(0x00000000);
}

/// Exposed so screens can reuse the prototype's gradient definitions.
class AppGradients {
  const AppGradients._();

  /// Weather banner: `#1E2B18` -> `#2C5F2D`, 135 degrees.
  static const LinearGradient weather = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.charcoal, AppColors.forest],
  );

  /// Festival banner: dark on the left fading out to the right.
  static const LinearGradient festivalBanner = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xE61E2B18), Color(0x4D1E2B18)],
  );

  /// Onboarding: transparent at the top, near-opaque charcoal at the bottom.
  static const LinearGradient onboarding = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.30, 0.80, 1.0],
    colors: <Color>[
      Color(0x00000000),
      Color(0xF21E2B18),
      Color(0xFF1E2B18),
    ],
  );

  /// Placeholder terrain behind the GPS location card.
  static const LinearGradient mapTerrain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFC8D8B0),
      Color(0xFF9BB080),
      Color(0xFF6E8F5A),
      Color(0xFF4A7050),
    ],
  );
}
