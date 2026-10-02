import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';
import 'app_status_bar.dart';

/// The cream form chrome shared by the registration and login screens: status
/// bar treatment, a back chevron, and a serif screen title.
class FormScreenScaffold extends StatelessWidget {
  const FormScreenScaffold({
    required this.title,
    required this.body,
    super.key,
    this.onBack,
  });

  final String title;
  final Widget body;

  /// Defaults to popping the route, which is what both screens want.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          const AppStatusBar(),
          FormAppBar(title: title, onBack: onBack),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Back chevron plus a serif title, sized to sit directly under the status bar.
class FormAppBar extends StatelessWidget {
  const FormAppBar({required this.title, super.key, this.onBack});

  final String title;
  final VoidCallback? onBack;

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 12),
          FormBackButton(onTap: onBack),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.serif,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

/// Bare back chevron, tinted for the light form background. Pops the route when
/// no callback is supplied.
class FormBackButton extends StatelessWidget {
  const FormBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: AppIconView(
                AppIcon.chevronLeft,
                size: 20,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Already have an account? Login" style footer: muted question, gold bold
/// action, laid out on a single centred line.
class AuthLinkPrompt extends StatelessWidget {
  const AuthLinkPrompt({
    required this.question,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            question,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13.5,
              color: AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Semantics(
          button: true,
          label: action,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                action,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
