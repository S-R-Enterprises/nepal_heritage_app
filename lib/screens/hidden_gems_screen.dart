import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/gem_card.dart';
import '../widgets/pill.dart';

/// Filterable feed of community-submitted gems.
class HiddenGemsScreen extends StatefulWidget {
  const HiddenGemsScreen({super.key});

  @override
  State<HiddenGemsScreen> createState() => _HiddenGemsScreenState();
}

class _HiddenGemsScreenState extends State<HiddenGemsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          const ScreenHeader(
            title: 'Hidden Gems',
            subtitle: 'Verified by local citizens \u00b7 Updated daily',
            background: AppColors.charcoal,
            bottomPadding: 16,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.parchment)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: <Widget>[
                        const AppIconView(
                          AppIcon.search,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Search gems\u2026',
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: InkWell(
                    onTap: () => router.go(AppScreen.submitGem),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          AppIconView(
                            AppIcon.plus,
                            size: 20,
                            color: AppColors.charcoal,
                            strokeWidth: 2.5,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Submit',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 52,
            color: AppColors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: MockData.gemFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final String label = MockData.gemFilters[index];
                return Pill(
                  label: label,
                  active: label == _filter,
                  onTap: () => setState(() => _filter = label),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Tall enough to fit a 160px image plus two text lines.
                childAspectRatio: 0.72,
              ),
              itemCount: MockData.gems.length,
              itemBuilder: (BuildContext context, int index) {
                final HiddenGem gem = MockData.gems[index];
                return GemCard(
                  gem: gem,
                  onTap: () => router.go(AppScreen.hiddenGemDetail),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
