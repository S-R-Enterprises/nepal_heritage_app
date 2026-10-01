import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import 'models.dart';

/// All static content in the app, transcribed from the `useState` initialisers
/// and inline literals in the Figma export.
class MockData {
  const MockData._();

  // ── Onboarding ─────────────────────────────────────────────────────────────

  static const List<OnboardingSlide> onboardingSlides =
      _OnboardingSlidesHolder.slides;

  // ── Home ───────────────────────────────────────────────────────────────────

  static const List<HeritageSite> heritageSites = <HeritageSite>[
    HeritageSite(
      name: 'Pashupatinath Temple',
      location: 'Kathmandu',
      rating: 4.9,
      image: Img.pashupati,
      entryFee: 'NPR 1,000',
    ),
    HeritageSite(
      name: 'Boudhanath Stupa',
      location: 'Kathmandu',
      rating: 4.8,
      image: Img.boudha,
      entryFee: 'NPR 400',
    ),
    HeritageSite(
      name: 'Patan Durbar Square',
      location: 'Lalitpur',
      rating: 4.7,
      image: Img.patan,
      entryFee: 'NPR 500',
    ),
    HeritageSite(
      name: 'Annapurna Base Camp',
      location: 'Gandaki',
      rating: 4.9,
      image: Img.annapurna,
      entryFee: 'NPR 3,000',
    ),
  ];

  static const List<QuickAction> quickActions = _QuickActionsHolder.items;

  static const WeatherDay today = WeatherDay(
    place: 'Kathmandu Valley',
    label: 'Today',
    temp: '22°',
    condition: 'Partly Cloudy',
  );

  static const List<WeatherDay> forecast = <WeatherDay>[
    WeatherDay(place: '', label: 'Mon', temp: '22°', condition: ''),
    WeatherDay(place: '', label: 'Tue', temp: '19°', condition: ''),
    WeatherDay(place: '', label: 'Wed', temp: '24°', condition: ''),
  ];

  static const FestivalBanner festivalBanner = FestivalBanner(
    name: 'Indra Jatra',
    dateRange: 'Oct 3\u201312 \u00b7 Kathmandu Durbar Square',
    image: Img.dance,
  );

  static const List<HiddenGem> gemsNearby = <HiddenGem>[
    HiddenGem(
      name: 'Shivapuri Peak Trail',
      location: '2.4km',
      distance: '2.4km',
      category: 'Viewpoint',
      image: Img.mountains,
      rating: 4.8,
    ),
    HiddenGem(
      name: 'Nagarkot Sunrise Spot',
      location: '34km',
      distance: '34km',
      category: 'Photography',
      image: Img.aerial,
      rating: 4.9,
    ),
  ];

  static const List<Guide> guides = <Guide>[
    Guide(
      name: 'Aarav Shrestha',
      specialty: 'Cultural & Heritage',
      rating: 4.9,
      price: r'$35/day',
      avatar: Img.avatarAarav,
    ),
    Guide(
      name: 'Priya Tamang',
      specialty: 'Trekking Expert',
      rating: 4.8,
      price: r'$40/day',
      avatar: Img.avatarPriya,
    ),
    Guide(
      name: 'Bibek Gurung',
      specialty: 'Photography Tours',
      rating: 4.7,
      price: r'$30/day',
      avatar: Img.avatarBibek,
    ),
  ];

  // ── Heritage detail ────────────────────────────────────────────────────────

  static const String heritageTitle = 'Pashupatinath Temple';
  static const String heritageSubtitle = 'Deopatan, Kathmandu \u00b7 UNESCO Heritage Site';
  static const double heritageRating = 4.9;
  static const String heritageReviewCount = '2,841 reviews';

  static const List<InfoTile> heritageInfo = <InfoTile>[
    InfoTile(label: 'Entry', value: 'NPR 1,000'),
    InfoTile(label: 'Opens', value: '6:00 AM'),
    InfoTile(label: 'Closes', value: '7:00 PM'),
    InfoTile(label: 'Best Time', value: 'Oct\u2013Mar'),
  ];

  static const List<String> heritageAbout = <String>[
    'Pashupatinath Temple is one of the most sacred Hindu temples in the world, '
        'dedicated to Lord Shiva. Situated on the banks of the holy Bagmati River, '
        'this UNESCO World Heritage Site attracts thousands of pilgrims and visitors daily.',
    'The temple complex encompasses 492 temples, monuments, ashrams, and inscriptions '
        'built over the centuries. Non-Hindu visitors may not enter the main temple but '
        'can observe the ghats and the surrounding complex.',
  ];

  static const List<String> heritageExpectations = <String>[
    'Aarti ceremony at sunrise and sunset',
    'Sacred cremation ghats on Bagmati River',
    '492+ temples within the complex',
    'Roaming sadhus \u2014 ask before photographing',
  ];

  static const String heritageTip =
      'Arrive before 7 AM to witness the morning Aarti ceremony. The atmosphere is '
      'extraordinary, with chanting and incense filling the air.';

  static const List<String> heritagePhotos = <String>[
    Img.pashupati,
    Img.boudha,
    Img.patan,
    Img.hero,
    Img.tower,
    Img.festival,
  ];

  static const List<Review> heritageReviews = <Review>[
    Review(
      name: 'Sarah Chen',
      date: 'Sep 2026',
      rating: 5,
      text: 'Absolutely breathtaking. The morning aarti is a spiritual experience '
          "unlike anything I've ever had. A must-visit.",
    ),
    Review(
      name: 'Marco Rossi',
      date: 'Aug 2026',
      rating: 5,
      text: 'Sacred and serene. The ghats along the Bagmati River carry centuries of '
          'tradition. Very moving.',
    ),
    Review(
      name: 'Emma Wilson',
      date: 'Jul 2026',
      rating: 4,
      text: 'Fascinating place, though quite crowded on weekends. Go early morning '
          'for the best experience.',
    ),
  ];

  // ── Ticket booking ─────────────────────────────────────────────────────────

  static const int adultPrice = 1000;
  static const int childPrice = 500;

  static const List<String> bookingDates = <String>[
    'Wed, Oct 8',
    'Thu, Oct 9',
    'Fri, Oct 10',
    'Sat, Oct 11',
    'Sun, Oct 12',
  ];

  static const String bookingDateYearSuffix = ', 2026';

  // ── Ticket confirm ─────────────────────────────────────────────────────────

  static const String bookingReference = 'NPH-2026-08142';
  static const String confirmDateLabel = 'Oct 8, 2026';

  // ── QR wallet ──────────────────────────────────────────────────────────────

  static const List<Ticket> tickets = <Ticket>[
    Ticket(
      site: 'Pashupatinath Temple',
      date: 'Oct 8, 2026',
      reference: 'NPH-2026-08142',
      adults: 1,
      status: TicketStatus.active,
    ),
    Ticket(
      site: 'Patan Durbar Square',
      date: 'Sep 22, 2026',
      reference: 'NPH-2026-07891',
      adults: 2,
      status: TicketStatus.used,
    ),
    Ticket(
      site: 'Boudhanath Stupa',
      date: 'Sep 10, 2026',
      reference: 'NPH-2026-07233',
      adults: 1,
      status: TicketStatus.used,
    ),
  ];

  // ── Hidden gems ────────────────────────────────────────────────────────────

  static const List<String> gemFilters = <String>[
    'All',
    'Near Me',
    'Viewpoints',
    'Temples',
    'Forests',
    'Trails',
  ];

  static const List<HiddenGem> gems = <HiddenGem>[
    HiddenGem(
      name: 'Shivapuri Peak Trail',
      location: 'Budhanilkantha',
      distance: '2.4km',
      category: 'Trail',
      image: Img.mountains,
      rating: 4.8,
    ),
    HiddenGem(
      name: 'Nagarkot Sunrise Spot',
      location: 'Bhaktapur',
      distance: '34km',
      category: 'Viewpoint',
      image: Img.aerial,
      rating: 4.9,
    ),
    HiddenGem(
      name: 'Khokana Hidden Temple',
      location: 'Lalitpur',
      distance: '12km',
      category: 'Temple',
      image: Img.tower,
      rating: 4.6,
    ),
    HiddenGem(
      name: 'Pulchowki Forest Walk',
      location: 'Lalitpur',
      distance: '16km',
      category: 'Forest',
      image: Img.village,
      rating: 4.7,
    ),
    HiddenGem(
      name: 'Sankhu Bajrayogini',
      location: 'Sankhu',
      distance: '22km',
      category: 'Temple',
      image: Img.patan,
      rating: 4.8,
    ),
    HiddenGem(
      name: 'Champadevi Summit',
      location: 'Kirtipur',
      distance: '10km',
      category: 'Viewpoint',
      image: Img.annapurna,
      rating: 4.6,
    ),
  ];

  // ── Hidden gem detail ──────────────────────────────────────────────────────

  static const HiddenGem featuredGem = HiddenGem(
    name: 'Shivapuri Peak Trail',
    location: 'Budhanilkantha',
    distance: '2.4km',
    category: 'Trail',
    image: Img.mountains,
    rating: 4.8,
  );

  static const List<InfoTile> gemStats = <InfoTile>[
    InfoTile(label: 'Altitude', value: '2,732m'),
    InfoTile(label: 'Duration', value: '3\u20134 hrs'),
    InfoTile(label: 'Difficulty', value: 'Moderate'),
    InfoTile(label: 'Best Time', value: 'Oct\u2013Apr'),
  ];

  static const String gemAbout =
      'A lesser-known trekking route to the summit of Shivapuri Peak, offering '
      'panoramic Himalayan views including Langtang, Ganesh Himal, and on clear '
      'days, the Everest range. Submitted and verified by local guide Aarav Shrestha.';

  static const String gemCoordinates = '27.8106\u00b0N, 85.3795\u00b0E';
  static const String gemElevation = '2,732m elevation';

  // ── Submit gem ─────────────────────────────────────────────────────────────

  static const List<String> gemCategories = <String>[
    'Viewpoint',
    'Temple',
    'Forest',
    'Trail',
    'Waterfall',
    'Village',
  ];

  static const String verificationCopy =
      'Our local team reviews each submission within 48 hours. Approved gems receive '
      'a gold Verified badge and are featured in the feed.';

  // ── Calendar ───────────────────────────────────────────────────────────────

  static const List<Festival> festivals = <Festival>[
    Festival(
      name: 'Indra Jatra',
      date: 'Oct 3\u201312',
      month: 'Oct',
      color: AppColors.festivalIndraJatra,
      image: Img.dance,
      description: "Kathmandu's grandest street festival celebrating Indra, god of rain.",
    ),
    Festival(
      name: 'Dashain',
      date: 'Oct 13\u201323',
      month: 'Oct',
      color: AppColors.festivalDashain,
      image: Img.flagGirl,
      description: "Nepal's most important Hindu festival. 15 days of family reunions "
          'and blessings.',
    ),
    Festival(
      name: 'Tihar',
      date: 'Nov 1\u20135',
      month: 'Nov',
      color: AppColors.festivalTihar,
      image: Img.streetFlags,
      description: 'The festival of lights. Diyas illuminate every home, honoring '
          'Lakshmi, the goddess of wealth.',
    ),
    Festival(
      name: 'Yomari Punhi',
      date: 'Nov 28',
      month: 'Nov',
      color: AppColors.festivalYomari,
      image: Img.patan,
      description: 'Newari harvest festival celebrated with sweet yomari rice dumplings.',
    ),
    Festival(
      name: 'Maha Shivaratri',
      date: 'Feb 26, 2027',
      month: 'Feb',
      color: AppColors.festivalShivaratri,
      image: Img.pashupati,
      description: 'Hundreds of thousands of pilgrims gather at Pashupatinath Temple.',
    ),
    Festival(
      name: 'Holi',
      date: 'Mar 14, 2027',
      month: 'Mar',
      color: AppColors.festivalHoli,
      image: Img.festival,
      description: 'The festival of colors \u2014 celebrated on the streets of Kathmandu '
          'and beyond.',
    ),
  ];

  static const String calendarRange = 'Oct 2026 \u2013 Mar 2027';

  /// October 2026 starts on a Thursday, so the grid has two leading blanks.
  static const int octoberLeadingBlanks = 2;
  static const int octoberDays = 31;

  // ── Festival detail ────────────────────────────────────────────────────────

  static const Festival featuredFestival = Festival(
    name: 'Indra Jatra',
    date: 'Oct 3\u201312, 2026',
    month: 'Oct',
    color: AppColors.festivalIndraJatra,
    image: Img.dance,
    description: '',
  );

  static const String festivalDuration = '10 Days';

  static const List<InfoTile> festivalInfo = <InfoTile>[
    InfoTile(label: 'Location', value: 'Kathmandu Durbar Square'),
    InfoTile(label: 'Crowd', value: 'Very Busy'),
  ];

  static const String festivalAbout =
      "Indra Jatra is Kathmandu's most spectacular street festival, celebrating "
      'Indra, the god of rain and king of heaven. The living goddess Kumari is '
      'paraded through the city on a wooden chariot. Crowds fill every street for 8 '
      'days of processions, masked dances, and pole raisings.';

  static const List<FestivalDay> festivalWeather = <FestivalDay>[
    FestivalDay(day: 'Oct 3', icon: '\u26C5', hi: 24, lo: 14),
    FestivalDay(day: 'Oct 4', icon: '\u2600\uFE0F', hi: 26, lo: 15),
    FestivalDay(day: 'Oct 5', icon: '\u2600\uFE0F', hi: 25, lo: 14),
    FestivalDay(day: 'Oct 6', icon: '\u1F324', hi: 22, lo: 13),
    FestivalDay(day: 'Oct 7', icon: '\u1F327', hi: 18, lo: 12),
    FestivalDay(day: 'Oct 8', icon: '\u26C5', hi: 21, lo: 13),
    FestivalDay(day: 'Oct 9', icon: '\u2600\uFE0F', hi: 25, lo: 14),
  ];

  static const List<Hotel> festivalHotels = <Hotel>[
    Hotel(
      name: 'Hotel Heritage Kathmandu',
      stars: 4,
      price: r'$45/night',
      distance: '0.3km',
      availability: 'Last 3 rooms',
    ),
    Hotel(
      name: 'Thamel Backpackers Hostel',
      stars: 3,
      price: r'$12/night',
      distance: '0.8km',
      availability: 'Available',
    ),
    Hotel(
      name: 'Durbar Square Homestay',
      stars: 4,
      price: r'$28/night',
      distance: '0.1km',
      availability: 'Last 1 room',
    ),
  ];

  static const List<String> festivalOffers = <String>[
    '15% off guided Durbar Square walks with Nepal Heritage app',
    'Free Cultural Tour with 3+ night hotel booking',
    'eSewa cashback: 5% on all ticket purchases during festival',
  ];

  // ── Guide profile ──────────────────────────────────────────────────────────

  static const String guideName = 'Aarav Shrestha';
  static const String guideCredentials =
      'Licensed Cultural Heritage Guide \u00b7 8 years experience';
  static const String guideReviewCount = '(187 reviews)';
  static const List<String> guideTags = <String>[
    'Cultural Heritage',
    'Temples',
    'Festivals',
    'History',
    'Photography',
  ];
  static const List<InfoTile> guideStats = <InfoTile>[
    InfoTile(label: 'Tours Led', value: '1,240'),
    InfoTile(label: 'Languages', value: 'EN, NP, HI'),
    InfoTile(label: 'Rate', value: r'$35/day'),
  ];
  static const String guideAbout =
      "Born and raised in Bhaktapur, I've spent 8 years guiding curious travelers "
      "through Nepal's living heritage. I specialize in the ancient royal cities of "
      'Kathmandu Valley \u2014 Kathmandu, Patan, and Bhaktapur \u2014 and love sharing '
      "the hidden stories that don't appear in guidebooks.";
  static const List<Review> guideReviews = <Review>[
    Review(
      name: 'Thomas K.',
      date: '',
      rating: 5,
      flag: '\u{1F1E9}\u{1F1EA}',
      text: 'Aarav transformed our Kathmandu visit. His knowledge of temple history '
          'and mythology was extraordinary.',
    ),
    Review(
      name: 'Yuki T.',
      date: '',
      rating: 5,
      flag: '\u{1F1EF}\u{1F1F5}',
      text: 'Incredibly knowledgeable and warm. He found us hidden courtyards tourists '
          'rarely see.',
    ),
  ];
  static const List<String> guideDates = <String>['Oct 8', 'Oct 9', 'Oct 10', 'Oct 11', 'Oct 12'];
  static const int guideHourlyRate = 35;

  // ── Profile ────────────────────────────────────────────────────────────────

  static const String userName = 'Alex Thompson';
  static const String userMeta = '\u{1F1EC}\u{1F1E7} United Kingdom \u00b7 Traveler';
  static const List<InfoTile> userStats = <InfoTile>[
    InfoTile(label: 'Trips', value: '3'),
    InfoTile(label: 'Tickets', value: '5'),
    InfoTile(label: 'Gems', value: '2'),
  ];

  static const List<BookingRecord> recentBookings = <BookingRecord>[
    BookingRecord(
      name: 'Pashupatinath Temple',
      type: 'Entry Ticket',
      date: 'Oct 8, 2026',
      status: 'Upcoming',
      image: Img.pashupati,
    ),
    BookingRecord(
      name: 'Aarav Shrestha',
      type: 'Heritage Guide',
      date: 'Oct 8, 2026',
      status: 'Upcoming',
      image: Img.avatarAarav,
    ),
    BookingRecord(
      name: 'Boudhanath Stupa',
      type: 'Entry Ticket',
      date: 'Sep 10, 2026',
      status: 'Completed',
      image: Img.boudha,
    ),
  ];

  static const List<SettingsRow> settingsRows = <SettingsRow>[
    SettingsRow(icon: '\u{1F310}', label: 'Language \u00b7 English'),
    SettingsRow(icon: '\u{1F4B1}', label: 'Currency \u00b7 NPR'),
    SettingsRow(icon: '\u{1F514}', label: 'Notifications'),
    SettingsRow(icon: '\u{1F512}', label: 'Privacy & Data'),
    SettingsRow(icon: '\u2753', label: 'Help & Support'),
  ];
}

class OnboardingSlide {
  const OnboardingSlide({required this.image, required this.title, required this.subtitle});

  final String image;
  final String title;
  final String subtitle;
}

class QuickAction {
  const QuickAction({required this.label, required this.icon, required this.color});

  final String label;
  final AppIcon icon;
  final Color color;
}

class WeatherDay {
  const WeatherDay({
    required this.place,
    required this.label,
    required this.temp,
    required this.condition,
  });

  final String place;
  final String label;
  final String temp;
  final String condition;
}

class FestivalBanner {
  const FestivalBanner({required this.name, required this.dateRange, required this.image});

  final String name;
  final String dateRange;
  final String image;
}

class InfoTile {
  const InfoTile({required this.label, required this.value});

  final String label;
  final String value;
}

class FestivalDay {
  const FestivalDay({required this.day, required this.icon, required this.hi, required this.lo});

  final String day;
  final String icon;
  final int hi;
  final int lo;
}

class SettingsRow {
  const SettingsRow({required this.icon, required this.label});

  final String icon;
  final String label;
}

class _OnboardingSlidesHolder {
  static const List<OnboardingSlide> slides = <OnboardingSlide>[
    OnboardingSlide(
      image: Img.hero,
      title: "Discover Nepal's Living Heritage",
      subtitle: 'Ancient temples, sacred mountains, and cultures that have endured '
          'for centuries \u2014 all in your pocket.',
    ),
    OnboardingSlide(
      image: Img.festival,
      title: 'Plan Around Festivals',
      subtitle: "Dashain, Tihar, Indra Jatra \u2014 know exactly when, where, and how "
          "to experience Nepal's greatest celebrations.",
    ),
    OnboardingSlide(
      image: Img.village,
      title: 'Hidden Gems by Locals',
      subtitle: 'Verified, off-the-beaten-path destinations submitted by local '
          'citizens who know Nepal best.',
    ),
  ];
}

class _QuickActionsHolder {
  static const List<QuickAction> items = <QuickAction>[
    QuickAction(label: 'Book Guide', icon: AppIcon.compass, color: AppColors.forest),
    QuickAction(label: 'QR Wallet', icon: AppIcon.qr, color: AppColors.moss),
    QuickAction(label: 'Weather', icon: AppIcon.sun, color: AppColors.weather),
    QuickAction(label: 'Hotels', icon: AppIcon.home, color: AppColors.hotels),
  ];
}
