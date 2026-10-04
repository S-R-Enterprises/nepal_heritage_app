import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_np/data/auth_service.dart';
import 'package:nepal_np/data/country_data.dart';
import 'package:nepal_np/data/language_data.dart';
import 'package:nepal_np/navigation/app_locale.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/login_screen.dart';
import 'package:nepal_np/screens/register_screen.dart';
import 'package:nepal_np/theme/app_theme.dart';
import 'package:nepal_np/widgets/form_fields.dart';
import 'package:nepal_np/widgets/glass.dart';

/// Same reasoning as `screens_test.dart`: measure with the shipped fonts rather
/// than the wide fallback, so layout assertions match the device.
Future<void> loadRealFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Lora': <String>['Lora-400normal.ttf', 'Lora-600normal.ttf', 'Lora-700normal.ttf'],
    'DMSans': <String>['DMSans-400normal.ttf', 'DMSans-500normal.ttf', 'DMSans-600normal.ttf'],
  };

  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String file in family.value) {
      loader.addFont(
        Future<ByteData>.value(
          ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }
}

/// Mounts [child] inside the two scopes every screen expects, and hands back the
/// router so tests can assert on navigation.
/// Mounts [child] inside the two scopes every screen expects, and hands back the
/// router so tests can assert on navigation.
///
/// The surface is deliberately very tall so the whole registration form is built
/// without scrolling. Overflow is covered separately in `screens_test.dart` at the
/// default phone size; here the point is the validation state machine, not
/// layout.
Future<AppRouter> pumpScreen(WidgetTester tester, Widget child) async {
  final AppRouter router = AppRouter();
  tester.view.physicalSize = const Size(420, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    AppLocaleScope(
      controller: AppLocaleController(),
      child: AppRouterScope(
        router: router,
        child: MaterialApp(theme: AppTheme.light, home: child),
      ),
    ),
  );
  await tester.pump();
  return router;
}

/// The text field carrying [hint].
///
/// Matched on the placeholder rather than the semantics label, because a
/// `Semantics` wrapper around a `TextField` folds its label into the field's own
/// node rather than producing a separate one to find.
Finder fieldWithHint(String hint) => find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.hintText == hint,
      description: 'TextField(hint: "$hint")',
    );

/// Taps [finder] once it is on screen. Most of these assertions run on a tall
/// surface where everything is already built, but the modal sheets it opens are
/// still constrained, so the scroll is kept as a safety net.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      160,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Fills every field the registration form requires, leaving country and audio
/// language to be chosen through their pickers.
Future<void> fillRegisterTextFields(
  WidgetTester tester, {
  String fullName = 'Prabika Rai',
  String address = 'Koteshwor, Kathmandu',
  String nationalId = '1234ABCD',
  String passport = 'P7654321',
  String phone = '9801234567',
  String email = 'prabika@example.com',
  String password = 'heritage123',
}) async {
  for (final MapEntry<String, String> entry in <String, String>{
    'e.g. Prabika Rai': fullName,
    'Street, city, state, postal code': address,
    'Alphanumeric ID number': nationalId,
    'e.g. P1234567': passport,
    '0000000000': phone,
    'you@example.com': email,
    'Create a password': password,
  }.entries) {
    await tester.enterText(fieldWithHint(entry.key), entry.value);
    await tester.pump();
  }
}

/// Opens a picker sheet, optionally searches it, and picks [option].
Future<void> pickFromSheet(
  WidgetTester tester, {
  required String option,
  String? search,
}) async {
  if (search != null) {
    await tester.enterText(fieldWithHint(search), option);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadRealFonts);

  group('registration', () {
    testWidgets('opens clean and reveals errors only after a field is left',
        (WidgetTester tester) async {
      await pumpScreen(tester, RegisterScreen(auth: AuthService()));

      // Nothing is flagged before the user has interacted with anything.
      expect(find.text('Full name is required'), findsNothing);
      expect(find.text('Gender is required'), findsNothing);

      // Typing is not enough on its own.
      await tester.enterText(fieldWithHint('e.g. Prabika Rai'), 'P');
      await tester.pump();
      expect(find.text('Enter at least 2 characters'), findsNothing);

      // Moving focus away from the field is.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Enter at least 2 characters'), findsOneWidget);

      // And it clears again as soon as the value is fixed.
      await tester.enterText(fieldWithHint('e.g. Prabika Rai'), 'Prabika Rai');
      await tester.pumpAndSettle();
      expect(find.text('Enter at least 2 characters'), findsNothing);
    });

    testWidgets('keeps the CTA disabled until every field passes validation',
        (WidgetTester tester) async {
      await pumpScreen(tester, RegisterScreen(auth: AuthService()));

      SolidActionButton button() =>
          tester.widget<SolidActionButton>(find.byType(SolidActionButton));
      expect(button().onPressed, isNull);

      await tester.enterText(fieldWithHint('e.g. Prabika Rai'), 'Prabika Rai');
      await tester.pumpAndSettle();
      // One field is not enough.
      expect(button().onPressed, isNull);

      // The gender segmented control has to feed the same validation pass.
      await scrollAndTap(tester, find.text('Female'));
      await tester.pumpAndSettle();
      expect(find.text('Gender is required'), findsNothing);

      await fillRegisterTextFields(tester, fullName: '');
      await tester.pumpAndSettle();
      // The name was blanked by the helper's default; the CTA must stay down.
      expect(button().onPressed, isNull);

      await fillRegisterTextFields(tester);
      await tester.pumpAndSettle();
      expect(button().onPressed, isNull, reason: 'country and audio language still empty');

      await scrollAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget w) => w is AppPickerField && w.placeholder == 'Select country',
        ),
      );
      await pickFromSheet(tester, option: 'India', search: 'Search by name or code');

      await scrollAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget w) => w is AppPickerField && w.placeholder == 'Select language',
        ),
      );
      await pickFromSheet(tester, option: 'Nepali');

      await tester.pumpAndSettle();
      expect(button().onPressed, isNotNull);
    });

    testWidgets('the password is required, length-checked and can be revealed',
        (WidgetTester tester) async {
      await pumpScreen(tester, RegisterScreen(auth: AuthService()));

      expect(find.text('Password is required'), findsNothing);

      // Too short, but only reported once the field has been left.
      await tester.enterText(fieldWithHint('Create a password'), 'abc');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Use at least 6 characters'), findsOneWidget);

      // And it clears as soon as the value is long enough.
      await tester.enterText(fieldWithHint('Create a password'), 'heritage123');
      await tester.pumpAndSettle();
      expect(find.text('Use at least 6 characters'), findsNothing);

      TextField field() =>
          tester.widget<TextField>(fieldWithHint('Create a password'));
      expect(field().obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      expect(field().obscureText, isFalse);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pumpAndSettle();
      expect(field().obscureText, isTrue);
    });

    testWidgets('changing the dial country re-checks the phone length',
        (WidgetTester tester) async {
      await pumpScreen(tester, RegisterScreen(auth: AuthService()));

      // Nepal's national numbers are 10 digits, so the hint says so.
      expect(fieldWithHint('0000000000'), findsOneWidget);

      await scrollAndTap(tester, find.byType(CountryCodeButton));
      await pickFromSheet(tester, option: 'Australia', search: 'Search by name or code');

      // Australia is 9 digits, and the expectation follows it.
      expect(fieldWithHint('000000000'), findsOneWidget);
      expect(fieldWithHint('0000000000'), findsNothing);

      await tester.enterText(fieldWithHint('000000000'), '12345');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.textContaining('Expected about 9 digits'), findsOneWidget);
    });

    testWidgets('reports the duplicate/identity mismatch from the service',
        (WidgetTester tester) async {
      final AppRouter router =
          await pumpScreen(tester, RegisterScreen(auth: AuthService()));

      await fillRegisterTextFields(tester, nationalId: 'P1234567', passport: 'p1234567');
      await scrollAndTap(tester, find.text('Female'));
      await scrollAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget w) => w is AppPickerField && w.placeholder == 'Select country',
        ),
      );
      await pickFromSheet(tester, option: 'India', search: 'Search by name or code');
      await scrollAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget w) => w is AppPickerField && w.placeholder == 'Select language',
        ),
      );
      await pickFromSheet(tester, option: 'Nepali');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SolidActionButton));
      await tester.pump();
      await tester.pump(AuthService.latency + const Duration(milliseconds: 200));

      expect(
        find.text('National ID and passport number must be different.'),
        findsOneWidget,
      );
      // Onboarding is only swapped in once the call succeeds, so the router must
      // not have moved off the entry flow.
      expect(router.screen, isNot(AppScreen.onboarding));
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('a successful registration swaps the stack for onboarding',
        (WidgetTester tester) async {
      final AppRouter router =
          await pumpScreen(tester, RegisterScreen(auth: AuthService()));

      await fillRegisterTextFields(tester);
      await scrollAndTap(tester, find.text('Female'));
      await scrollAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget w) => w is AppPickerField && w.placeholder == 'Select country',
        ),
      );
      await pickFromSheet(tester, option: 'India', search: 'Search by name or code');
      await scrollAndTap(
        tester,
        find.byWidgetPredicate(
          (Widget w) => w is AppPickerField && w.placeholder == 'Select language',
        ),
      );
      await pickFromSheet(tester, option: 'Nepali');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SolidActionButton));
      await tester.pump();
      await tester.pump(AuthService.latency + const Duration(milliseconds: 200));

      expect(router.screen, AppScreen.onboarding);
      expect(router.canPop, isFalse, reason: 'the finished form must not be reachable');
    });
  });

  group('login', () {
    const String identifierHint = 'you@example.com or +977 98XXXXXXXX';
    const String passwordHint = 'At least 6 characters';

    testWidgets('a first-time identifier is sent to onboarding',
        (WidgetTester tester) async {
      final AppRouter router =
          await pumpScreen(tester, LoginScreen(auth: AuthService()));

      await tester.enterText(fieldWithHint(identifierHint), 'newcomer@example.com');
      await tester.enterText(fieldWithHint(passwordHint), AuthService.demoPassword);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SolidActionButton));
      await tester.pump();
      await tester.pump(AuthService.latency + const Duration(milliseconds: 200));

      expect(router.screen, AppScreen.onboarding);
      expect(router.canPop, isFalse);
    });

    testWidgets('the demo account has already seen onboarding and goes to home',
        (WidgetTester tester) async {
      final AppRouter router =
          await pumpScreen(tester, LoginScreen(auth: AuthService()));

      await tester.enterText(fieldWithHint(identifierHint), AuthService.demoEmail);
      await tester.enterText(fieldWithHint(passwordHint), AuthService.demoPassword);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SolidActionButton));
      await tester.pump();
      await tester.pump(AuthService.latency + const Duration(milliseconds: 200));

      expect(router.screen, AppScreen.home);
      expect(router.showTabs, isTrue);
    });

    testWidgets('the CTA wakes up once both fields have content',
        (WidgetTester tester) async {
      await pumpScreen(tester, LoginScreen(auth: AuthService()));

      SolidActionButton button() =>
          tester.widget<SolidActionButton>(find.byType(SolidActionButton));
      expect(button().onPressed, isNull);

      await tester.enterText(fieldWithHint(identifierHint), 'a@b.com');
      await tester.pumpAndSettle();
      expect(button().onPressed, isNull, reason: 'password still empty');

      await tester.enterText(fieldWithHint(passwordHint), 'abc');
      await tester.pumpAndSettle();
      // Too short: the inline hint appears, but the tap is still allowed so the
      // service can reject it with a proper message.
      expect(find.text('Use at least 6 characters'), findsOneWidget);
      expect(button().onPressed, isNotNull);

      await tester.enterText(fieldWithHint(passwordHint), 'abcdef');
      await tester.pumpAndSettle();
      expect(find.text('Use at least 6 characters'), findsNothing);
      expect(button().onPressed, isNotNull);
    });

    testWidgets('a short password is rejected with the message under the button',
        (WidgetTester tester) async {
      final AppRouter router =
          await pumpScreen(tester, LoginScreen(auth: AuthService()));

      await tester.enterText(fieldWithHint(identifierHint), 'a@b.com');
      await tester.enterText(fieldWithHint(passwordHint), 'abc');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SolidActionButton));
      await tester.pump();
      await tester.pump(AuthService.latency + const Duration(milliseconds: 200));

      expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
      expect(router.screen, isNot(AppScreen.home));
    });

    testWidgets('an empty identifier keeps the button down',
        (WidgetTester tester) async {
      await pumpScreen(tester, LoginScreen(auth: AuthService()));

      await tester.enterText(fieldWithHint(identifierHint), '   ');
      await tester.enterText(fieldWithHint(passwordHint), 'abcdef');
      await tester.pumpAndSettle();

      expect(
        tester.widget<SolidActionButton>(find.byType(SolidActionButton)).onPressed,
        isNull,
      );
    });

    testWidgets('the password can be revealed and hidden again',
        (WidgetTester tester) async {
      await pumpScreen(tester, LoginScreen(auth: AuthService()));

      TextField field() => tester.widget<TextField>(fieldWithHint(passwordHint));
      expect(field().obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      expect(field().obscureText, isFalse);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pumpAndSettle();
      expect(field().obscureText, isTrue);
    });

    testWidgets('a rejected sign-in stays put', (WidgetTester tester) async {
      final AppRouter router =
          await pumpScreen(tester, LoginScreen(auth: AuthService()));

      await tester.enterText(fieldWithHint(identifierHint), 'a@b.com');
      await tester.enterText(fieldWithHint(passwordHint), 'short');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SolidActionButton));
      await tester.pump();
      await tester.pump(AuthService.latency + const Duration(milliseconds: 200));

      expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
      expect(router.screen, isNot(AppScreen.home));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('AuthService', () {
    RegistrationRequest request({
      String email = 'prabika@example.com',
      String nationalId = '1234ABCD',
      String passport = 'P7654321',
      String password = 'heritage123',
    }) =>
        RegistrationRequest(
          fullName: 'Prabika Rai',
          address: 'Koteshwor',
          gender: Gender.female,
          nationalId: nationalId,
          passportNumber: passport,
          dialCode: Countries.nepal.dialCode,
          phone: '9801234567',
          email: email,
          password: password,
          country: Countries.nepal,
          audioGuideLanguage: AudioGuideLanguages.nepali,
        );

    test('an unknown identifier signs in as a first-time user', () async {
      final AuthService auth = AuthService();
      final AuthUser user = await auth.login(
        identifier: 'prabika.rai@example.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(user.completedOnboarding, isFalse);
      expect(user.fullName, 'Prabika Rai');
    });

    test('marking onboarding complete makes later logins skip the carousel',
        () async {
      final AuthService auth = AuthService();
      final AuthUser first = await auth.login(
        identifier: 'prabika@example.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      await auth.markOnboardingComplete(first);

      final AuthUser second = await auth.login(
        identifier: 'prabika@example.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(second.completedOnboarding, isTrue);
    });

    test('an account created by phone number is still found on the next login',
        () async {
      final AuthService auth = AuthService();
      await auth.login(
        identifier: '9801234567',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(auth.hasSession, isTrue);

      // The email does not match the key, but the id does, so the flag lands.
      final AuthUser byPhone = auth.currentUser!;
      await auth.markOnboardingComplete(byPhone);

      final AuthUser again = await auth.login(
        identifier: '9801234567',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(again.id, byPhone.id);
      expect(again.completedOnboarding, isTrue);
    });

    test('a short password is rejected with a message', () async {
      final AuthService auth = AuthService();
      expect(
        () => auth.login(identifier: 'a@b.com', password: 'abc', rememberMe: false),
        throwsA(
          isA<AuthException>().having((AuthException e) => e.message, 'message', contains('6')),
        ),
      );
    });

    test('an account signs in with the password it was registered with', () async {
      final AuthService auth = AuthService();
      await auth.register(request(password: 'secret123'));

      final AuthUser user = await auth.login(
        identifier: 'prabika@example.com',
        password: 'secret123',
        rememberMe: false,
      );
      expect(user.email, 'prabika@example.com');
    });

    test('an incorrect password is rejected for a registered account', () async {
      final AuthService auth = AuthService();
      await auth.register(request(password: 'secret123'));

      expect(
        () => auth.login(
          identifier: 'prabika@example.com',
          password: 'secret124',
          rememberMe: false,
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('Incorrect password'),
          ),
        ),
      );
    });

    test('registration rejects a password below the minimum length', () async {
      final AuthService auth = AuthService();
      expect(
        () => auth.register(request(password: 'abc')),
        throwsA(isA<AuthException>()),
      );
    });

    test('an empty identifier is rejected with a message', () async {
      final AuthService auth = AuthService();
      expect(
        () => auth.login(identifier: '   ', password: 'heritage123', rememberMe: false),
        throwsA(isA<AuthException>()),
      );
    });

    test('registration rejects a duplicate email', () async {
      final AuthService auth = AuthService();
      await auth.register(request());
      expect(
        () => auth.register(request()),
        throwsA(isA<AuthException>()),
      );
    });

    test('registration rejects a national ID equal to the passport number',
        () async {
      final AuthService auth = AuthService();
      expect(
        () => auth.register(request(nationalId: 'P1', passport: 'p1')),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('different'),
          ),
        ),
      );
    });

    test('a new registration is a first-time user', () async {
      final AuthService auth = AuthService();
      final AuthUser user = await auth.register(request());
      expect(user.completedOnboarding, isFalse);
    });

    test('the request serialises to the shape an API would take', () {
      final Map<String, Object?> json = request().toJson();
      expect(json['fullName'], 'Prabika Rai');
      expect(json['gender'], 'female');
      expect(json['country'], 'NP');
      expect(json['audioGuideLanguage'], 'ne');
      expect(json['dialCode'], '+977');
      expect(json['phone'], '9801234567');
      expect(json['password'], 'heritage123');
    });

    test('signing out clears the session', () async {
      final AuthService auth = AuthService();
      await auth.login(
        identifier: 'a@b.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(auth.hasSession, isTrue);
      auth.signOut();
      expect(auth.hasSession, isFalse);
      expect(auth.currentUser, isNull);
    });

    test('the reset endpoint accepts any non-empty identifier', () async {
      final AuthService auth = AuthService();
      await auth.requestPasswordReset('a@b.com');
      expect(
        () => auth.requestPasswordReset('  '),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
