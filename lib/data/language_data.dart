import 'package:flutter/widgets.dart';

/// A language the app can be shown in, chosen from the landing screen's language
/// selector.
///
/// This is the *display* language. It is deliberately separate from the audio
/// guide language picked on the registration form, which drives narration
/// content rather than UI chrome.
class DisplayLanguage {
  const DisplayLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.locale,
  });

  /// ISO 639-1 code, e.g. `en`.
  final String code;
  final String englishName;
  final String nativeName;
  final Locale locale;

  /// Two-or-three letter form shown inside the selector pill.
  String get shortLabel => code.toUpperCase();
}

class DisplayLanguages {
  const DisplayLanguages._();

  static const List<DisplayLanguage> all = <DisplayLanguage>[
    DisplayLanguage(
      code: 'en',
      englishName: 'English',
      nativeName: 'English',
      locale: Locale('en'),
    ),
    DisplayLanguage(
      code: 'ne',
      englishName: 'Nepali',
      nativeName: 'नेपाली',
      locale: Locale('ne'),
    ),
    DisplayLanguage(
      code: 'hi',
      englishName: 'Hindi',
      nativeName: 'हिन्दी',
      locale: Locale('hi'),
    ),
    DisplayLanguage(
      code: 'zh',
      englishName: 'Chinese',
      nativeName: '中文',
      locale: Locale('zh'),
    ),
    DisplayLanguage(
      code: 'fr',
      englishName: 'French',
      nativeName: 'Français',
      locale: Locale('fr'),
    ),
    DisplayLanguage(
      code: 'es',
      englishName: 'Spanish',
      nativeName: 'Español',
      locale: Locale('es'),
    ),
    DisplayLanguage(
      code: 'de',
      englishName: 'German',
      nativeName: 'Deutsch',
      locale: Locale('de'),
    ),
    DisplayLanguage(
      code: 'ja',
      englishName: 'Japanese',
      nativeName: '日本語',
      locale: Locale('ja'),
    ),
    DisplayLanguage(
      code: 'ko',
      englishName: 'Korean',
      nativeName: '한국어',
      locale: Locale('ko'),
    ),
    DisplayLanguage(
      code: 'ar',
      englishName: 'Arabic',
      nativeName: 'العربية',
      locale: Locale('ar'),
    ),
  ];

  /// The language the app opens in.
  static const DisplayLanguage english = DisplayLanguage(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    locale: Locale('en'),
  );
}

/// A language the recorded audio guides are available in.
class AudioGuideLanguage {
  const AudioGuideLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
  });

  final String code;
  final String englishName;
  final String nativeName;

  /// `English`, shown in the dropdown.
  String get label => englishName;
}

class AudioGuideLanguages {
  const AudioGuideLanguages._();

  static const List<AudioGuideLanguage> all = <AudioGuideLanguage>[
    AudioGuideLanguage(code: 'ne', englishName: 'Nepali', nativeName: 'नेपाली'),
    AudioGuideLanguage(code: 'en', englishName: 'English', nativeName: 'English'),
    AudioGuideLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
    AudioGuideLanguage(code: 'zh', englishName: 'Chinese', nativeName: '中文'),
    AudioGuideLanguage(code: 'fr', englishName: 'French', nativeName: 'Français'),
    AudioGuideLanguage(code: 'es', englishName: 'Spanish', nativeName: 'Español'),
    AudioGuideLanguage(code: 'de', englishName: 'German', nativeName: 'Deutsch'),
    AudioGuideLanguage(code: 'ja', englishName: 'Japanese', nativeName: '日本語'),
    AudioGuideLanguage(code: 'ko', englishName: 'Korean', nativeName: '한국어'),
    AudioGuideLanguage(code: 'ar', englishName: 'Arabic', nativeName: 'العربية'),
    AudioGuideLanguage(code: 'ru', englishName: 'Russian', nativeName: 'Русский'),
    AudioGuideLanguage(code: 'pt', englishName: 'Portuguese', nativeName: 'Português'),
    AudioGuideLanguage(code: 'it', englishName: 'Italian', nativeName: 'Italiano'),
    AudioGuideLanguage(code: 'th', englishName: 'Thai', nativeName: 'ไทย'),
    AudioGuideLanguage(code: 'vi', englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
    AudioGuideLanguage(code: 'id', englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
  ];

  /// The default narration language.
  static const AudioGuideLanguage nepali = AudioGuideLanguage(
    code: 'ne',
    englishName: 'Nepali',
    nativeName: 'नेपाली',
  );
}
