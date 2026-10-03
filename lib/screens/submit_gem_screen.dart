import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/coming_soon.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a place name before submitting.')),
      );
      return;
    }
    MockData.gemSubmissions.add(<String, String>{
      'name': name,
      'category': _category,
      'description': _descriptionController.text.trim(),
    });
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    // Drop any validation-error SnackBar still on screen; otherwise the
    // confirmation queues behind its full duration and appears far too late.
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('"$name" submitted for verification.')),
    );
    AppRouterScope.back(context);
  }

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
                  _EditableField(
                    label: 'Place Name',
                    hint: 'e.g. Shivapuri Ridge Viewpoint',
                    controller: _nameController,
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
                  _EditableField(
                    label: 'Description',
                    hint: 'Describe what makes this place special, how to get '
                        'there, best time to visit…',
                    controller: _descriptionController,
                    maxLines: 3,
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
            child: PrimaryButton(
              label: 'Submit for Verification',
              onPressed: _submit,
            ),
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
    return GestureDetector(
      onTap: () => showComingSoon(
        context,
        title: 'Photo Upload',
        blurb:
            'Photo uploads arrive with the moderation backend. Add the place '
            'details now — you can attach photos when that ships.',
      ),
      child: Container(
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
      ),
    );
  }
}

/// Labelled text input styled to match the form cards.
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FieldLabel(label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            minLines: maxLines == 1 ? null : maxLines,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              height: 1.6,
              color: AppColors.charcoal,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintMaxLines: maxLines,
              hintStyle: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                height: 1.6,
                color: maxLines == 1 ? AppColors.charcoal : AppColors.muted,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.parchment),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.parchment),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.forest, width: 1.5),
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
    return GestureDetector(
      onTap: () => showComingSoon(
        context,
        title: 'GPS Location',
        blurb:
            'Dropping a pin on the map arrives in a later release, together '
            'with automatic location capture.',
      ),
      child: AppCard(
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
      ),
    );
  }
}
