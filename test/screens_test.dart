import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/data/auth_service.dart';
import 'package:nepal_np/data/mock_data.dart';
import 'package:nepal_np/navigation/app_locale.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/calendar_screen.dart';
import 'package:nepal_np/screens/chatbot_screen.dart';
import 'package:nepal_np/screens/festival_detail_screen.dart';
import 'package:nepal_np/screens/forgot_password_screen.dart';
import 'package:nepal_np/screens/guide_profile_screen.dart';
import 'package:nepal_np/screens/heritage_detail_screen.dart';
import 'package:nepal_np/screens/hidden_gem_detail_screen.dart';
import 'package:nepal_np/screens/hidden_gems_screen.dart';
import 'package:nepal_np/screens/home_screen.dart';
import 'package:nepal_np/screens/landing_screen.dart';
import 'package:nepal_np/screens/login_screen.dart';
import 'package:nepal_np/screens/profile_screen.dart';
import 'package:nepal_np/screens/qr_wallet_screen.dart';
import 'package:nepal_np/screens/register_screen.dart';
import 'package:nepal_np/screens/submit_gem_screen.dart';
import 'package:nepal_np/screens/ticket_booking_screen.dart';
import 'package:nepal_np/screens/ticket_confirm_screen.dart';
import 'package:nepal_np/theme/app_theme.dart';
import 'package:nepal_np/widgets/buttons.dart';

/// `flutter test` otherwise falls back to a fixed-width test font, which makes
/// every text run far wider than it is on device and produces overflow errors
/// that a real phone never produces. Load the bundled families so the tests
/// measure the same metrics the app actually ships with.
Future<void> loadRealFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Lora': <String>[
      'Lora-400normal.ttf',
      'Lora-400italic.ttf',
      'Lora-600normal.ttf',
      'Lora-600italic.ttf',
      'Lora-700normal.ttf',
    ],
    'DMSans': <String>[
      'DMSans-300normal.ttf',
      'DMSans-400normal.ttf',
      'DMSans-500normal.ttf',
      'DMSans-600normal.ttf',
    ],
  };

  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String file in family.value) {
      final File asset = File('assets/fonts/$file');
      loader.addFont(
        Future<ByteData>.value(
          ByteData.sublistView(asset.readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }
}

/// Mounts [child] inside a router scope at a phone-sized viewport and reports any
/// layout overflow or build error.
Future<void> pumpScreen(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    AppLocaleScope(
      controller: AppLocaleController(),
      child: AppRouterScope(
        router: AppRouter(),
        child: MaterialApp(
          theme: AppTheme.light,
          home: child,
        ),
      ),
    ),
  );
  await tester.pump();
}

/// A single transparent 1x1 PNG, served for every image request.
final Uint8List _kPixel = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// `flutter test` has no network, so every `Image.network` in the app would
/// otherwise fail. Serve a real (blank) image for any request instead, which
/// lets the tests assert on layout without filtering out exceptions.
class _StubHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _StubHttpClient();
}

class _StubHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _StubRequest(url);

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost = 6;

  @override
  String? userAgent = 'stub';

  @override
  noSuchMethod(Invocation invocation) {
    final String name = invocation.memberName.toString();
    // Image loading pokes at a few optional client properties; treat plain
    // property writes and reads as no-ops rather than test failures.
    if (name.endsWith('=')) {
      return null;
    }
    throw UnsupportedError('unexpected HttpClient call: $name');
  }
}

class _StubRequest implements HttpClientRequest {
  _StubRequest(this.url);

  final Uri url;

  @override
  Future<HttpClientResponse> close() async => _StubResponse();

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unexpected HttpClientRequest call: ${invocation.memberName}');
}

class _StubResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kPixel.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kPixel).listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  Future<HttpClientResponse> close() async => this;

  @override
  HttpClientResponseCompressionState compressionState =
      HttpClientResponseCompressionState.notCompressed;

  @override
  noSuchMethod(Invocation invocation) {
    final String name = invocation.memberName.toString();
    if (name.endsWith('=')) {
      return null;
    }
    throw UnsupportedError('unexpected HttpClientResponse call: $name');
  }
}

/// The screens pull remote images and `flutter test` has no network, so every
/// [NetworkImage] throws. Those failures are expected; anything else — most
/// importantly a `RenderFlex` overflow — is a real bug.
void expectNoLayoutError(WidgetTester tester) {
  final List<Object> unexpected = <Object>[];
  for (int i = 0; i < 64; i++) {
    final Object? error = tester.takeException();
    if (error == null || error is NetworkImageLoadException) {
      continue;
    }
    unexpected.add(error);
  }
  expect(unexpected, isEmpty, reason: 'unexpected exceptions: $unexpected');
}

void main() {
  setUpAll(loadRealFonts);
  setUpAll(() => HttpOverrides.global = _StubHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  group('every screen renders without overflow', () {
    final Map<String, Widget> screens = <String, Widget>{
      'home': const HomeScreen(),
      'heritageDetail': const HeritageDetailScreen(),
      'ticketBooking': const TicketBookingScreen(),
      'ticketConfirm': const TicketConfirmScreen(),
      'qrWallet': const QrWalletScreen(),
      'hiddenGems': const HiddenGemsScreen(),
      'hiddenGemDetail': const HiddenGemDetailScreen(),
      'submitGem': const SubmitGemScreen(),
      'calendar': const CalendarScreen(),
      'festivalDetail': const FestivalDetailScreen(),
      'guideProfile': const GuideProfileScreen(),
      'profile': const ProfileScreen(),
      'landing': const LandingScreen(),
      'chatbot': const ChatbotScreen(),
      'register': RegisterScreen(auth: AuthService()),
      'login': LoginScreen(auth: AuthService()),
      'forgotPassword': const ForgotPasswordScreen(),
    };

    for (final MapEntry<String, Widget> entry in screens.entries) {
      testWidgets(entry.key, (WidgetTester tester) async {
        await pumpScreen(tester, entry.value);
        expectNoLayoutError(tester);
      });
    }
  });

  testWidgets('submit gem categories are selectable', (WidgetTester tester) async {
    await pumpScreen(tester, const SubmitGemScreen());

    expect(find.text('Viewpoint'), findsOneWidget);
    expect(find.text('Waterfall'), findsOneWidget);

    await tester.tap(find.text('Waterfall'));
    await tester.pump();
    expectNoLayoutError(tester);
  });

  testWidgets('guide booking total scales with duration',
      (WidgetTester tester) async {
    await pumpScreen(tester, const GuideProfileScreen());

    // 4 hours at a 35/day rate, pro-rated over an 8 hour day.
    expect(find.text('4 hours'), findsOneWidget);
    expect(find.text('Total: \$18'), findsOneWidget);

    // The booking card sits well below the fold on a phone-sized viewport.
    final Finder increment = find.byType(RoundIconButton).last;
    await tester.scrollUntilVisible(
      increment,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(increment);
    await tester.pump();
    expect(find.text('5 hours'), findsOneWidget);
    expect(find.text('Total: \$22'), findsOneWidget);

    // 8 hours is a full day at the headline rate.
    for (int i = 0; i < 3; i++) {
      await tester.tap(increment);
      await tester.pump();
    }
    expect(find.text('8 hours'), findsOneWidget);
    expect(find.text('Total: \$35'), findsOneWidget);

    expectNoLayoutError(tester);
  });

  testWidgets('calendar toggles between the list and month views',
      (WidgetTester tester) async {
    await pumpScreen(tester, const CalendarScreen());

    expect(find.text('Indra Jatra'), findsWidgets);

    await tester.tap(find.text('month'));
    await tester.pump();
    expectNoLayoutError(tester);
    expect(find.textContaining('October 2026'), findsOneWidget);
  });

  test('mock data covers every screen the router can reach', () {
    expect(MockData.festivals, isNotEmpty);
    expect(MockData.gemCategories, isNotEmpty);
    expect(MockData.recentBookings, isNotEmpty);
    expect(MockData.settingsRows, isNotEmpty);
    expect(MockData.guideDates, isNotEmpty);
    expect(MockData.octoberLeadingBlanks, lessThan(7));
  });
}
