import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/coming_soon.dart';
import '../widgets/network_photo.dart';
import '../widgets/pill.dart';

/// Full detail for a single hidden gem: stats, description, a stylised map
/// placeholder and the submitter's credentials.
class HiddenGemDetailScreen extends StatefulWidget {
  const HiddenGemDetailScreen({super.key});

  @override
  State<HiddenGemDetailScreen> createState() => _HiddenGemDetailScreenState();
}

class _HiddenGemDetailScreenState extends State<HiddenGemDetailScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);
    // The tapped gem (gems feed or home grid); featuredGem is the fallback.
    final HiddenGem gem =
        router.arg is HiddenGem ? router.arg as HiddenGem : MockData.featuredGem;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 260,
            child: PhotoScrim(
              url: gem.image,
              gradient: const <String>[
                'rgba(0,0,0,0.25)',
                'rgba(0,0,0,0)',
                'rgba(30,43,24,0.8)',
              ],
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 16,
                      top: 12,
                      child: AppBackButton(
                        light: true,
                        onPressed: () => AppRouterScope.back(context),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const VerifiedBadge(),
                          const SizedBox(height: 8),
                          Text(
                            gem.name,
                            style: const TextStyle(
                              fontFamily: AppFonts.serif,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LocationLine(
                            '${gem.location}, Kathmandu \u00b7 ${gem.distance} away',
                            color: AppColors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  InfoTileRow(
                    tiles: <({String label, String value})>[
                      for (final InfoTile tile in MockData.gemStats)
                        (label: tile.label, value: tile.value),
                    ],
                    background: AppColors.white,
                    valueSize: 11,
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'About This Gem',
                          style: AppText.serifSmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          MockData.gemAbout,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _MapCard(),
                  const SizedBox(height: 16),
                  const _SubmitterCard(),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: Row(
              children: <Widget>[
                OutlineActionButton(
                  label: _saved ? 'Saved' : 'Save',
                  borderColor: AppColors.forest,
                  foregroundColor: AppColors.forest,
                  onPressed: () => setState(() => _saved = !_saved),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                    child: Material(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: InkWell(
                        onTap: () => showComingSoon(
                          context,
                          title: 'Guided Walks',
                          blurb:
                              'Audio guided walks arrive in a later release — '
                              'the route, stories and offline mode are still '
                              'being built.',
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            AppIconView(
                              AppIcon.compass,
                              size: 18,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Start Guided Walk',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylised offline map with a pin, matching the prototype's SVG placeholder.
class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('GPS Location', style: AppText.serifSmall),
              const Text(
                'Open in Maps \u2192',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: AppGradients.mapTerrain,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned.fill(
                  child: CustomPaint(painter: _MapGridPainter()),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x4D000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const AppIconView(
                          AppIcon.mapPin,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                      // Little triangle forming the pin's tail.
                      CustomPaint(
                        size: const Size(12, 8),
                        painter: _PinTailPainter(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _CoordinateChip('\u{1F4CD} ${MockData.gemCoordinates}'),
              _CoordinateChip('\u{1F3D4} ${MockData.gemElevation}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoordinateChip extends StatelessWidget {
  const _CoordinateChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}

/// Faint grid + two road curves, reproducing the prototype's inline SVGs.
class _MapGridPainter extends CustomPainter {
  const _MapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = AppColors.forest
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      final double y = i * (size.height / 7);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (int i = 0; i < 20; i++) {
      final double x = i * (size.width / 19);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    final Paint road = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x998FAB70)
      ..strokeWidth = 6;

    final Path main = Path()
      ..moveTo(size.width * 0.12, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.7,
        size.width * 0.9,
        size.height * 0.35,
      );
    canvas.drawPath(main, road);

    road
      ..color = const Color(0x997A9B60)
      ..strokeWidth = 4;
    final Path secondary = Path()
      ..moveTo(size.width * 0.05, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.55,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.8,
        size.width * 0.95,
        size.height * 0.5,
      );
    canvas.drawPath(secondary, road);
  }

  @override
  bool shouldRepaint(_MapGridPainter oldDelegate) => false;
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Path tail = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(tail, Paint()..color = AppColors.forest);
  }

  @override
  bool shouldRepaint(_PinTailPainter oldDelegate) => false;
}

class _SubmitterCard extends StatelessWidget {
  const _SubmitterCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          const Avatar(url: Img.avatarAaravSmall, size: 44),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Submitted & verified by',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${MockData.guideName} \u00b7 Local Guide',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.125),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppIconView(AppIcon.shield, size: 14, color: AppColors.gold),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
