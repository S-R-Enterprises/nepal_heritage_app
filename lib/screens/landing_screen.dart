import 'dart:async';

import 'package:flutter/material.dart';

import '../data/language_data.dart';
import '../data/models.dart';
import '../navigation/app_locale.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_status_bar.dart';
import '../widgets/glass.dart';
import '../widgets/network_photo.dart';
import '../widgets/picker_sheet.dart';

/// The first thing a visitor sees: a full-bleed photo carousel with the app's
/// value proposition, the three feature pills, and the calls to action.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  /// The five heritage photos the carousel cycles through. Reuses the URLs
  /// already wired into the rest of the app so nothing here needs new assets.
  static const List<String> _photos = <String>[
    Img.pashupati,
    Img.dance,
    Img.mountains,
    Img.village,
    Img.tower,
  ];

  static const Duration _slideInterval = Duration(seconds: 5);

  late final PageController _pageController = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Restarts the countdown whenever the user swipes, so a manual swipe is not
  /// immediately followed by a timer-driven jump.
  void _startAutoAdvance() {
    _timer?.cancel();
    _timer = Timer.periodic(_slideInterval, (Timer _) => _next());
  }

  void _next() {
    if (!mounted || !_pageController.hasClients) {
      return;
    }
    final int target = (_page + 1) % _photos.length;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // ── Background carousel ────────────────────────────────────────────
          _BackgroundCarousel(
            controller: _pageController,
            photos: _photos,
            onPageChanged: (int index) {
              setState(() => _page = index);
              _startAutoAdvance();
            },
          ),

          // ── Fixed legibility scrim ─────────────────────────────────────────
          // Sits above the carousel as a single fixed layer, so it is not
          // rebuilt when the slide changes and the text stays readable on every
          // photo: dense at the top for the language/auth row, light through the
          // middle, dense again at the bottom for the CTAs.
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.landingScrim),
            child: SizedBox.expand(),
          ),

          const Align(
            alignment: Alignment.topCenter,
            child: AppStatusBar(light: true),
          ),

          // ── Content column ─────────────────────────────────────────────────
          Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _TopRow(
                    onLogin: () => AppRouterScope.go(context, AppScreen.login),
                    onRegister: () => AppRouterScope.go(context, AppScreen.register),
                  ),
                ),
              ),

              // The centre block sits in the upper-middle third: two parts of
              // flexible space above it, three below, which puts it just above
              // the vertical midpoint on a tall phone.
              const Spacer(flex: 20),
              _CentreBlock(photoCount: _photos.length, activePage: _page),
              const Spacer(flex: 30),

              SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 20),
                  child: _LowerSection(
                    photoCount: _photos.length,
                    activePage: _page,
                    onGetStarted: () =>
                        AppRouterScope.go(context, AppScreen.login),
                    onSignIn: () => AppRouterScope.go(context, AppScreen.login),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom safe-area strip ─────────────────────────────────────────
          // A solid band below the photo, with a decorative gesture bar, so the
          // carousel does not run under the home indicator.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomSafeStrip(height: bottomInset),
          ),
        ],
      ),
    );
  }
}

/// The photo layer.
///
/// Each page crossfades: it fades in when it becomes the current slide and back
/// out when it stops being current, while the [PageView] transition does the
/// horizontal movement. That gives the dissolve the design asks for on both the
/// timer-driven and the swipe-driven path.
class _BackgroundCarousel extends StatefulWidget {
  const _BackgroundCarousel({
    required this.controller,
    required this.photos,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<String> photos;
  final ValueChanged<int> onPageChanged;

  @override
  State<_BackgroundCarousel> createState() => _BackgroundCarouselState();
}

class _BackgroundCarouselState extends State<_BackgroundCarousel> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.controller.hasClients || !widget.controller.position.isScrollingNotifier.value) {
      return;
    }
    // Pick whichever page is closest to fully visible. The PageController's page
    // is fractional mid-swipe, so rounding it gives the slide that has "won".
    final double page = widget.controller.page ?? 0;
    final int index = page.round().clamp(0, widget.photos.length - 1);
    if (index != _current) {
      setState(() => _current = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.photos.length,
      onPageChanged: widget.onPageChanged,
      // Full-bleed slides: no peeking at the neighbouring photo.
      allowImplicitScrolling: false,
      itemBuilder: (BuildContext context, int index) {
        return _CrossfadeSlide(
          active: index == _current,
          child: NetworkPhoto(
            key: ValueKey<String>(widget.photos[index]),
            url: widget.photos[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

/// Fades its child in and out as [active] flips, matching the carousel's slide
/// timing.
class _CrossfadeSlide extends StatelessWidget {
  const _CrossfadeSlide({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
      child: child,
    );
  }
}

/// Language selector on the left, Login / Register on the right.
class _TopRow extends StatelessWidget {
  const _TopRow({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _LanguageSelector(),
        const Spacer(),
        GlassPill(
          label: 'Login',
          onTap: onLogin,
          fontWeight: FontWeight.w700,
          semanticLabel: 'Log in',
        ),
        const SizedBox(width: 8),
        _GoldPill(label: 'Register', onTap: onRegister),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final AppLocaleController locale = AppLocaleScope.of(context);
    final DisplayLanguage current = locale.language;

    return GlassPill(
      // A custom child rather than GlassPill's icon+label row, because the
      // trailing chevron sits on the right of the text here.
      label: current.shortLabel,
      icon: AppIcon.globe,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      onTap: () => _open(context),
      semanticLabel: 'Language, ${current.englishName}',
    );
  }

  Future<void> _open(BuildContext context) async {
    final AppLocaleController locale = AppLocaleScope.read(context);
    final DisplayLanguage? picked = await showPickerSheet<DisplayLanguage>(
      context: context,
      title: 'Language',
      options: DisplayLanguages.all,
      labelBuilder: (DisplayLanguage l) => l.englishName,
      trailingBuilder: (DisplayLanguage l) => l.nativeName,
      isSelected: (DisplayLanguage l) => l.code == locale.language.code,
      onSelected: (DisplayLanguage l) => locale.select(l),
    );
    // Nothing to do on dismissal; the sheet already closed itself.
    if (picked == null) {
      return;
    }
  }
}

/// Solid gold pill with dark forest text, used for the Register action.
class _GoldPill extends StatelessWidget {
  const _GoldPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.forest,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo badge, greeting pill, headline, subheading and the carousel dashes.
///
/// [activePage] comes from the background carousel so the dashes stay in step
/// with the photo behind them.
class _CentreBlock extends StatelessWidget {
  const _CentreBlock({required this.photoCount, required this.activePage});

  final int photoCount;
  final int activePage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AppLogoBadge(),
          const SizedBox(height: 12),
          const _NamastePill(),
          const SizedBox(height: 12),
          FittedBox(
            // Keeps "Nepal Heritage" on one line even at the largest permitted
            // text scale on a narrow phone.
            fit: BoxFit.scaleDown,
            child: Text.rich(
              const TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: 'Nepal '),
                  TextSpan(
                    text: 'Heritage',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.serif,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.3,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover sacred temples, hidden Himalayan gems, living festivals, '
            'and authentic journeys across Nepal.',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              height: 1.55,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 8),
          _PageDashes(count: photoCount, active: activePage),
        ],
      ),
    );
  }
}

/// The greeting pill: outlined, gold border, hand glyph plus letter-spaced caps.
class _NamastePill extends StatelessWidget {
  const _NamastePill();

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      opacity: 0.4,
      borderColor: AppColors.gold,
      semanticLabel: 'Namaste, welcome',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AppIconView(AppIcon.hand, size: 14, color: AppColors.gold),
          const SizedBox(width: 7),
          Text(
            'Namaste · Welcome',
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal dash segments — one per slide, active one filled gold.
class _PageDashes extends StatelessWidget {
  const _PageDashes({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: 16,
            height: 3,
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.gold
                  : AppColors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

/// Feature pills, the primary CTA, the sign-in link and the trust line.
class _LowerSection extends StatelessWidget {
  const _LowerSection({
    required this.photoCount,
    required this.activePage,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final int photoCount;
  final int activePage;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const _FeaturePills(),
        const SizedBox(height: 16),
        _GetStartedButton(onPressed: onGetStarted),
        const SizedBox(height: 12),
        _SignInPrompt(onSignIn: onSignIn),
        const SizedBox(height: 8),
        const _TrustLine(),
      ],
    );
  }
}

class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  @override
  Widget build(BuildContext context) {
    // Wrapped rather than a fixed row: on a 360dp phone the three labels do not
    // fit side by side, and the design allows them to wrap.
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        GlassPill(
          label: 'Verified Gems',
          icon: AppIcon.checkCircle,
          iconColor: AppColors.moss,
          opacity: 0.4,
        ),
        GlassPill(
          label: 'Instant Entry',
          icon: AppIcon.ticket,
          iconColor: AppColors.gold,
          opacity: 0.4,
        ),
        GlassPill(
          label: 'Live Weather',
          icon: AppIcon.cloud,
          iconColor: AppColors.cream,
          opacity: 0.4,
        ),
      ],
    );
  }
}

/// The gold "Get Started" pill: bold dark text with a trailing arrow.
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(width: 8),
                AppIconView(
                  AppIcon.arrowRight,
                  size: 18,
                  color: AppColors.charcoal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Already registered? Sign In" on one line, with a tappable gold span.
class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    const TextStyle base = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 13.5,
      color: AppColors.white,
    );
    const TextStyle link = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: AppColors.gold,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Flexible(
          child: Text(
            'Already registered?',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: base,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSignIn,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text('Sign In', style: link),
          ),
        ),
      ],
    );
  }
}

/// Shield glyph plus the uppercase platform claim.
class _TrustLine extends StatelessWidget {
  const _TrustLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const AppIconView(AppIcon.shieldCheck, size: 13, color: AppColors.moss),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'OFFICIAL SMART TOURISM PLATFORM OF NEPAL',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
              height: 1.35,
              color: AppColors.cream.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

/// The solid band below the photo, sized to the real bottom inset so the
/// gesture bar sits inside it.
class _BottomSafeStrip extends StatelessWidget {
  const _BottomSafeStrip({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    // On a device with no gesture inset the strip would vanish entirely, which
    // looks like a rendering bug in a simulator and in tests, so keep a floor.
    final double band = height < 12 ? 12 : height;

    return Container(
      height: band,
      color: AppColors.charcoal,
      alignment: Alignment.center,
      child: const HomeIndicatorBar(),
    );
  }
}
