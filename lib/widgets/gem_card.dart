import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';
import 'network_photo.dart';
import 'pill.dart';

/// How much of a [GemCard] to show.
enum GemCardLayout {
  /// Square-ish tile for the two-up grid on the home screen: thumbnail plus
  /// name and distance.
  compact,

  /// Full card for the Hidden Gems feed: taller thumbnail, category tag and a
  /// second line carrying the location and rating.
  full,
}

/// A hidden-gem tile. The prototype renders these twice with slightly different
/// content, so both variants live here behind [GemCardLayout].
class GemCard extends StatelessWidget {
  const GemCard({
    required this.gem,
    required this.onTap,
    super.key,
    this.layout = GemCardLayout.full,
  });

  final HiddenGem gem;
  final VoidCallback onTap;
  final GemCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final bool full = layout == GemCardLayout.full;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(full ? AppRadii.xxl : AppRadii.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: full ? 160 : 100,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  NetworkPhoto(url: gem.image),
                  const Positioned(left: 10, top: 10, child: VerifiedTag(withIcon: true)),
                  if (full)
                    Positioned(right: 10, top: 10, child: CategoryTag(gem.category)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    gem.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: full ? 13 : 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColors.charcoal,
                    ),
                  ),
                  SizedBox(height: full ? 6 : 4),
                  if (full)
                    Row(
                      children: <Widget>[
                        Expanded(child: LocationLine(gem.distance)),
                        RatingStars(gem.rating),
                      ],
                    )
                  else
                    LocationLine('${gem.distance} away'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
