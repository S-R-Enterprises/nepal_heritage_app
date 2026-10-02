import 'package:flutter/material.dart';

/// Design tokens ported 1:1 from the Figma Make export
/// (`src/index.css` `@theme` block + the `C` object in `src/App.tsx`).
class AppColors {
  const AppColors._();

  static const Color forest = Color(0xFF2C5F2D);
  static const Color moss = Color(0xFF6E8F5A);
  static const Color gold = Color(0xFFC9A227);
  static const Color cream = Color(0xFFF5F1E6);
  static const Color charcoal = Color(0xFF1E2B18);
  static const Color parchment = Color(0xFFEDE8DA);
  static const Color muted = Color(0xFF8A9B7A);
  static const Color white = Color(0xFFFFFFFF);

  /// Body copy colour used for long-form descriptions (`#4A5C44` in App.tsx).
  static const Color body = Color(0xFF4A5C44);

  /// Inactive bottom-tab icon colour (`#A0ADA0` in App.tsx).
  static const Color tabInactive = Color(0xFFA0ADA0);

  /// Form validation error text. Deliberately a muted red rather than one of the
  /// brand colours, so a problem never reads as a branded highlight.
  static const Color error = Color(0xFFA8382C);

  /// Neutral outline for unselected / resting form controls.
  static const Color fieldBorder = Color(0xFFD8D0BC);

  // Semantic colours used by the calendar / festival screens.
  static const Color festivalIndraJatra = Color(0xFF8B5CF6);
  static const Color festivalDashain = Color(0xFFEF4444);
  static const Color festivalTihar = Color(0xFFC9A227);
  static const Color festivalYomari = Color(0xFF6E8F5A);
  static const Color festivalShivaratri = Color(0xFFF97316);
  static const Color festivalHoli = Color(0xFFEC4899);

  // Payment provider brand colours.
  static const Color esewa = Color(0xFF60BB46);
  static const Color khalti = Color(0xFF5C2D91);
  static const Color card = Color(0xFF1A56DB);

  // Quick-action tints from the home screen grid.
  static const Color weather = Color(0xFFD97706);
  static const Color hotels = Color(0xFF7C3AED);
}

class AppFonts {
  const AppFonts._();

  static const String serif = 'Lora';
  static const String body = 'DMSans';
}

class AppRadii {
  const AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;
  static const double card = 20;
  static const double pill = 24;
  static const double hero = 44;
}

class AppShadows {
  const AppShadows._();

  static const Color _tint = Color(0x142C5F2D);

  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> get card => const <BoxShadow>[
        BoxShadow(color: _tint, blurRadius: 8, spreadRadius: 0, offset: Offset(0, 1)),
      ];

  static List<BoxShadow> get raised => const <BoxShadow>[
        BoxShadow(color: Color(0x1A2C5F2D), blurRadius: 12, offset: Offset(0, 2)),
      ];

  static List<BoxShadow> get floating => const <BoxShadow>[
        BoxShadow(color: Color(0x262C5F2D), blurRadius: 20, offset: Offset(0, 4)),
      ];
}

/// A ready-made [ThemeData] for the app. The design has no Material component
/// theming of its own, so this mostly wires up typography, colours and the
/// transparent page transition used by the router.
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ColorScheme scheme =
        ColorScheme.fromSeed(seedColor: AppColors.forest).copyWith(
      primary: AppColors.forest,
      secondary: AppColors.gold,
      surface: AppColors.white,
      onSurface: AppColors.charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: AppFonts.body,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme,
    );
  }

  static const TextTheme _textTheme = TextTheme(
    // Serif display styles, used for every screen title.
    displaySmall: TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
      color: AppColors.charcoal,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.charcoal,
    ),
    headlineSmall: TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.charcoal,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.charcoal,
    ),
    titleMedium: TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.charcoal,
    ),
    titleSmall: TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.charcoal,
    ),
    // Sans-serif UI styles.
    labelLarge: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.charcoal,
    ),
    labelMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.charcoal,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.7,
      color: AppColors.body,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.charcoal,
    ),
    labelSmall: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.muted,
    ),
  );
}

/// Serif heading sizes that fall between the standard [TextTheme] slots.
class AppText {
  const AppText._();

  /// 16px serif — card-level headings such as "About This Gem".
  static const TextStyle serifSmall = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.charcoal,
  );

  /// 15px serif — list-row headings such as a festival name.
  static const TextStyle serifRow = TextStyle(
    fontFamily: AppFonts.serif,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.charcoal,
  );
}
