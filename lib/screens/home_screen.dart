import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_status_bar.dart';
import '../widgets/gem_card.dart';
import '../widgets/network_photo.dart';
import '../widgets/pill.dart';

/// Landing screen: weather banner, quick actions, festival banner, heritage
/// sites, hidden gems and guides.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      floatingActionButton: const ChatFabButton(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _Header(router: router)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: const _WeatherBanner(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverToBoxAdapter(child: _QuickActionsGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverToBoxAdapter(child: _FestivalBanner()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SectionHeader(
                title: 'Heritage Sites',
                actionLabel: 'See all →',
                onAction: () => router.go(AppScreen.allSites),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _HeritageSitesRow(router: router)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Hidden Gems Nearby',
              actionLabel: 'Explore \u2192',
              onAction: () => router.go(AppScreen.hiddenGems),
            ),
          ),
          const SliverToBoxAdapter(child: _GemsGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Top Guides',
              actionLabel: 'See all →',
              onAction: () => router.go(AppScreen.allGuides),
            ),
          ),
          SliverToBoxAdapter(child: _GuidesRow(router: router)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Chat button ───────────────────────────────────────────────────────────────

/// The floating entry point to the AI assistant.
///
/// Gold rather than the tab-bar forest so it separates from the dark home
/// header it overlaps, with the chat glyph repeated on the assistant's own
/// header.
class ChatFabButton extends StatelessWidget {
  const ChatFabButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open AI heritage assistant',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppShadows.floating,
        ),
        child: Material(
          color: AppColors.gold,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => AppRouterScope.go(context, AppScreen.chatbot),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: AppIconView(
                  AppIcon.chat,
                  size: 22,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.forest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AppStatusBar(light: true),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Good morning \u{1F64F}',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            color: Color(0xA6FFFFFF),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Namaste, Alex',
                          style: TextStyle(
                            fontFamily: AppFonts.serif,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: NetworkPhoto(
                      url: Img.avatarUser,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SearchField(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          AppIconView(
            AppIcon.search,
            size: 18,
            color: AppColors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Text(
            'Search temples, treks, festivals\u2026',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather ───────────────────────────────────────────────────────────────────

class _WeatherBanner extends StatelessWidget {
  const _WeatherBanner();

  @override
  Widget build(BuildContext context) {
    final WeatherDay today = MockData.today;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppGradients.weather,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${today.place} \u00b7 ${today.label}',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: Color(0x99FFFFFF),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    today.temp,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    today.condition,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      color: Color(0x99FFFFFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final WeatherDay day in MockData.forecast)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        day.label,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 11,
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        day.temp,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < MockData.quickActions.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(action: MockData.quickActions[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    // Only the QR Wallet tile is wired up in the prototype; the rest are
    // presentational.
    final bool enabled = action.label == 'QR Wallet';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: enabled ? () => AppRouterScope.go(context, AppScreen.qrWallet) : null,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Center(
                  child: AppIconView(action.icon, size: 18, color: action.color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Festival banner ───────────────────────────────────────────────────────────

class _FestivalBanner extends StatelessWidget {
  const _FestivalBanner();

  @override
  Widget build(BuildContext context) {
    final FestivalBanner banner = MockData.festivalBanner;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => AppRouterScope.go(context, AppScreen.festivalDetail),
          child: SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                NetworkPhoto(url: banner.image),
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.festivalBanner),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '\u{1F3AD} UPCOMING FESTIVAL',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        banner.name,
                        style: const TextStyle(
                          fontFamily: AppFonts.serif,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner.dateRange,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          color: AppColors.white.withValues(alpha: 0.75),
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
    );
  }
}

// ── Heritage sites ────────────────────────────────────────────────────────────

class _HeritageSitesRow extends StatelessWidget {
  const _HeritageSitesRow({required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Tall enough for the worst case: a two-line site name plus the
      // location/rating row and the entry-fee chip.
      height: 238,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.heritageSites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          final HeritageSite site = MockData.heritageSites[index];
          return SizedBox(
            width: 190,
            child: AppCard(
              radius: AppRadii.xxl,
              padding: EdgeInsets.zero,
              shadows: AppShadows.raised,
              onTap: () => router.go(AppScreen.heritageDetail),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: NetworkPhoto(url: site.image),
                  ),
                  Padding(
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(child: LocationLine(site.location)),
                            RatingStars(site.rating),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.forest.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Entry fee',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                site.entryFee,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hidden gems ───────────────────────────────────────────────────────────────

class _GemsGrid extends StatelessWidget {
  const _GemsGrid();

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < MockData.gemsNearby.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: GemCard(
                gem: MockData.gemsNearby[i],
                layout: GemCardLayout.compact,
                onTap: () => router.go(AppScreen.hiddenGemDetail),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Guides ────────────────────────────────────────────────────────────────────

class _GuidesRow extends StatelessWidget {
  const _GuidesRow({required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MockData.guides.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final Guide guide = MockData.guides[index];
          return SizedBox(
            width: 155,
            child: AppCard(
              radius: AppRadii.xl,
              padding: const EdgeInsets.all(14),
              onTap: () => router.go(AppScreen.guideProfile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Avatar(url: guide.avatar, size: 52),
                  const SizedBox(height: 10),
                  Text(
                    guide.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
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
                      fontSize: 11,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
