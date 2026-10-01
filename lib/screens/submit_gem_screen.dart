import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/pill.dart';
import 'heritage_detail_screen.dart' show LocalTip;

/// Community submission form for a new hidden gem.
class SubmitGemScreen extends StatefulWidget {
  const SubmitGemScreen({super.key});

  @override
  State<SubmitGemScreen> createState() => _SubmitGemScreenState();
}

class _SubmitGemScreenState extends State<SubmitGemScreen> {
  String _category = 'Viewpoint';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'Submit a Hidden Gem',
            subtitle: "Help travelers discover Nepal's secrets",
            onBack: () => AppRouterScope.back(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const _PhotoUploadTile(),
                  const SizedBox(height: 16),
                  const _PlaceholderField(
                    label: 'Place Name',
                    hint: 'e.g. Shivapuri Ridge Viewpoint',
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const FieldLabel('Category'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final String category in MockData.gemCategories)
                              Pill(
                                label: category,
                                active: category == _category,
                                onTap: () =>
                                    setState(() => _category = category),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _GpsCard(),
                  const SizedBox(height: 14),
                  const _PlaceholderField(
                    label: 'Description',
                    hint: 'Describe what makes this place special, how to get '
                        'there, best time to visit\u2026',
                    minHeight: 80,
                    hintColor: AppColors.muted,
                  ),
                  const SizedBox(height: 16),
                  LocalTip(
                    title: '\u{1F50D} Verification Process',
                    text: MockData.verificationCopy,
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(label: 'Submit for Verification'),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadTile extends StatelessWidget {
  const _PhotoUploadTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.parchment, width: 2),
      ),
      child: Column(
        children: <Widget>[
          const AppIconView(AppIcon.upload, size: 20, color: AppColors.muted),
          const SizedBox(height: 8),
          const Text(
            'Add Photos',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to upload up to 5 photos',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A read-only field showing placeholder text, mirroring the prototype's static
/// inputs. Swap for a real `TextField` when this form is wired to a backend.
class _PlaceholderField extends StatelessWidget {
  const _PlaceholderField({
    required this.label,
    required this.hint,
    this.minHeight,
    this.hintColor = AppColors.charcoal,
  });

  final String label;
  final String hint;
  final double? minHeight;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    final double? minHeight = this.minHeight;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FieldLabel(label),
          const SizedBox(height: 8),
          Container(
            constraints:
                minHeight == null ? null : BoxConstraints(minHeight: minHeight),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.parchment)),
            ),
            child: Text(
              hint,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                height: 1.6,
                color: hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsCard extends StatelessWidget {
  const _GpsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FieldLabel('GPS Location'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.moss.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.moss, width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppIconView(AppIcon.mapPin, size: 14, color: AppColors.forest),
                SizedBox(width: 8),
                Text(
                  'Drop Pin on Map',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Or your current location will be used',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
