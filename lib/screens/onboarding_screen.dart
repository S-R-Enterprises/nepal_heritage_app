import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_status_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/network_photo.dart';

/// Three-slide intro carousel. `Skip` and the final button both enter the app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final List<OnboardingSlide> slides = MockData.onboardingSlides;
    final OnboardingSlide slide = slides[_step];
    final bool isLast = _step == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Cross-fade between slide images.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: NetworkPhoto(
              key: ValueKey<String>(slide.image),
              url: slide.image,
              fit: BoxFit.cover,
            ),
          ),
          Opacity(opacity: 0.6, child: Container(color: AppColors.charcoal)),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.onboarding),
            child: SizedBox.expand(),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: AppStatusBar(light: true),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Dots(count: slides.length, active: _step),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        key: ValueKey<int>(_step),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontFamily: AppFonts.serif,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.3,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slide.subtitle,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (isLast)
                      PrimaryButton(
                        label: 'Explore Nepal \u2192',
                        onPressed: _continue,
                        verticalPadding: 18,
                        fontSize: 16,
                      )
                    else
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _GhostButton(
                              label: 'Skip',
                              onPressed: _continue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              label: 'Next \u2192',
                              onPressed: () => setState(() => _step++),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continue() => AppRouterScope.of(context).start();
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: 4,
            width: i == active ? 24 : 8,
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.gold
                  : AppColors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 15,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
