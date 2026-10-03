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

/// Festival detail: overview, a seven-day forecast, nearby stays and offers.
class FestivalDetailScreen extends StatelessWidget {
  const FestivalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Festival festival = MockData.featuredFestival;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 240,
            child: PhotoScrim(
              url: festival.image,
              gradient: const <String>[
                'rgba(0,0,0,0.3)',
                'rgba(139,92,246,0.5)',
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
                      bottom: 16,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: festival.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '\u{1F3AD} CULTURAL FESTIVAL',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            festival.name,
                            style: const TextStyle(
                              fontFamily: AppFonts.serif,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${festival.date} \u00b7 ${MockData.festivalDuration}',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 13,
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
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
                      for (final InfoTile tile in MockData.festivalInfo)
                        (label: tile.label, value: tile.value),
                    ],
                    background: AppColors.white,
                    valueSize: 12,
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Text(
                      MockData.festivalAbout,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ForecastCard(),
                  const SizedBox(height: 20),
                  const _HotelsSection(),
                  const SizedBox(height: 16),
                  const _OffersCard(),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: 'Plan My Festival Trip →',
              color: AppColors.festivalIndraJatra,
              foregroundColor: AppColors.white,
              onPressed: () => showComingSoon(
                context,
                title: 'Festival Trip Planner',
                blurb:
                    'A day-by-day festival itinerary builder is coming in a '
                    'later release. For now, browse the hotels and offers below.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('Festival Weather Forecast', bottom: 14),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.festivalWeather.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final FestivalDay day = MockData.festivalWeather[index];
                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        day.day,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(day.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        '${day.hi}\u00b0',
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        '${day.lo}\u00b0',
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 11,
                          color: AppColors.muted,
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

class _HotelsSection extends StatelessWidget {
  const _HotelsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardHeading('Nearby Hotels & Homestays', bottom: 0),
        ),
        for (final Hotel hotel in MockData.festivalHotels)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              radius: AppRadii.lg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('\u{1F3E8}', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          hotel.name,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Text(
                              '${hotel.distance} from festival',
                              style: const TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hotel.availability,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: hotel.isScarce
                                    ? const Color(0xFFEF4444)
                                    : AppColors.moss,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    hotel.price,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest,
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

class _OffersCard extends StatelessWidget {
  const _OffersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('\u{1F3F7}\uFE0F Festival Offers', bottom: 10),
          for (final String offer in MockData.festivalOffers)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: AppIconView(
                      AppIcon.check,
                      size: 16,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      offer,
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
    );
  }
}
