import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/buttons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/network_photo.dart';
import '../widgets/pill.dart';

enum _DetailTab { about, photos, reviews }

/// Heritage site detail with About / Photos / Reviews tabs and a sticky
/// "Book Entry Ticket" footer.
class HeritageDetailScreen extends StatefulWidget {
  const HeritageDetailScreen({super.key});

  @override
  State<HeritageDetailScreen> createState() => _HeritageDetailScreenState();
}

class _HeritageDetailScreenState extends State<HeritageDetailScreen> {
  _DetailTab _tab = _DetailTab.about;
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 280,
            child: PhotoScrim(
              url: Img.pashupati,
              gradient: const <String>[
                'rgba(0,0,0,0.3)',
                'rgba(0,0,0,0)',
                'rgba(30,43,24,0.7)',
              ],
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          AppBackButton(
                            light: true,
                            onPressed: () => AppRouterScope.back(context),
                          ),
                          Semantics(
                            button: true,
                            label: _favourite ? 'Remove from favourites' : 'Add to favourites',
                            child: GlassIconButton(
                              icon: AppIcon.heart,
                              onPressed: () =>
                                  setState(() => _favourite = !_favourite),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              RatingStars(MockData.heritageRating),
                              const SizedBox(width: 6),
                              Text(
                                '\u00b7 ${MockData.heritageReviewCount}',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 12,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            MockData.heritageTitle,
                            style: const TextStyle(
                              fontFamily: AppFonts.serif,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LocationLine(
                            MockData.heritageSubtitle,
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
          _InfoStrip(
            tiles: <({String label, String value})>[
              for (final InfoTile tile in MockData.heritageInfo)
                (label: tile.label, value: tile.value),
            ],
          ),
          _Tabs(
            current: _tab,
            onChanged: (_DetailTab value) => setState(() => _tab = value),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: switch (_tab) {
                _DetailTab.about => const _AboutTab(),
                _DetailTab.photos => const _PhotosTab(),
                _DetailTab.reviews => const _ReviewsTab(),
              },
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: 'Book Entry Ticket',
              icon: AppIcon.ticket,
              color: AppColors.forest,
              foregroundColor: AppColors.white,
              onPressed: () => router.go(AppScreen.ticketBooking),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.tiles});

  final List<({String label, String value})> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.white,
      child: InfoTileRow(tiles: tiles),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.current, required this.onChanged});

  final _DetailTab current;
  final ValueChanged<_DetailTab> onChanged;

  static const Map<_DetailTab, String> _labels = <_DetailTab, String>{
    _DetailTab.about: 'About',
    _DetailTab.photos: 'Photos',
    _DetailTab.reviews: 'Reviews',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          for (final _DetailTab tab in _DetailTab.values)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: current == tab ? AppColors.forest : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _labels[tab]!,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    fontWeight:
                        current == tab ? FontWeight.w600 : FontWeight.w400,
                    color: current == tab ? AppColors.forest : AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final String paragraph in MockData.heritageAbout)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              paragraph,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CardHeading('What to Expect', fontSize: 14),
              for (final String item in MockData.heritageExpectations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const AppIconView(
                        AppIcon.check,
                        size: 16,
                        color: AppColors.forest,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const LocalTip(text: MockData.heritageTip),
      ],
    );
  }
}

/// Gold-accented "Local Tip" callout, reused on the gem submission screen.
class LocalTip extends StatelessWidget {
  const LocalTip({required this.text, super.key, this.title = 'Local Tip'});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border(left: const BorderSide(color: AppColors.gold, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              height: 1.5,
              color: AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab();

  @override
  Widget build(BuildContext context) {
    final List<String> photos = MockData.heritagePhotos;

    // The prototype makes the first photo span both columns at a taller aspect,
    // then fills the remainder as a two-up grid.
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: SizedBox(height: 180, width: double.infinity, child: NetworkPhoto(url: photos.first)),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: photos.length - 1,
          itemBuilder: (BuildContext context, int index) => ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: NetworkPhoto(url: photos[index + 1]),
          ),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final Review review in MockData.heritageReviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: AppRadii.lg,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.forest,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          review.name.characters.first,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              review.name,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                            Text(
                              review.date,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StarRow(count: review.rating),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.text,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
