import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/network_photo.dart';
import '../widgets/pill.dart';

/// "See all →" destinations from the home screen: the full heritage-site and
/// guide collections. Taps currently open the shared detail screens; per-item
/// payloads arrive with the router refactor.
class AllSitesScreen extends StatelessWidget {
  const AllSitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'Heritage Sites',
            subtitle: '${MockData.heritageSites.length} places to explore',
            onBack: () => AppRouterScope.back(context),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: MockData.heritageSites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final HeritageSite site = MockData.heritageSites[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  shadows: AppShadows.raised,
                  onTap: () =>
                      AppRouterScope.go(context, AppScreen.heritageDetail),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadii.xxl),
                            bottomLeft: Radius.circular(AppRadii.xxl),
                          ),
                          child: NetworkPhoto(url: site.image),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                site.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: LocationLine(site.location),
                                  ),
                                  const SizedBox(width: 8),
                                  RatingStars(site.rating),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Entry ${site.entryFee}',
                                style: const TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forest,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Guides counterpart of [AllSitesScreen], backing the home "See all →".
class AllGuidesScreen extends StatelessWidget {
  const AllGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'Top Guides',
            subtitle: '${MockData.guides.length} local experts',
            onBack: () => AppRouterScope.back(context),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: MockData.guides.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final Guide guide = MockData.guides[index];
                return AppCard(
                  onTap: () =>
                      AppRouterScope.go(context, AppScreen.guideProfile),
                  child: Row(
                    children: <Widget>[
                      Avatar(url: guide.avatar, size: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              guide.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              guide.specialty,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RatingStars(guide.rating),
                                Text(
                                  guide.price,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.body,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forest,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
