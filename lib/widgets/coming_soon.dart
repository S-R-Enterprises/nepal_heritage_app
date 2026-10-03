import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'buttons.dart';

/// Honest bottom sheet for v2 features, used instead of a button that looks
/// tappable and then does nothing.
Future<void> showComingSoon(
  BuildContext context, {
  required String title,
  required String blurb,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'COMING SOON',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.forest.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.serif,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                blurb,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.body,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Got it',
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      );
    },
  );
}
