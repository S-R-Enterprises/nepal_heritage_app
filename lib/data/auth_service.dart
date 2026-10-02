import '../data/country_data.dart';
import '../data/language_data.dart';

/// Gender options on the registration form.
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.label);

  final String label;
}

/// Everything the registration form collects, in the shape a real
/// `POST /auth/register` body would take.
class RegistrationRequest {
  const RegistrationRequest({
    required this.fullName,
    required this.address,
    required this.gender,
    required this.nationalId,
    required this.passportNumber,
    required this.dialCode,
    required this.phone,
    required this.email,
    required this.password,
    required this.country,
    required this.audioGuideLanguage,
  });

  final String fullName;
  final String address;
  final Gender gender;
  final String nationalId;
  final String passportNumber;

  /// International prefix, kept separate from [phone] so the stored number is
  /// unambiguous regardless of which country the account was made in.
  final String dialCode;
  final String phone;
  final String email;

  /// Chosen on the form and checked on the next sign-in. A real client would
  /// send this in the request body and the server would store only a hash; the
  /// in-memory store keeps the plaintext so the fake round-trip can verify it.
  final String password;

  final Country country;
  final AudioGuideLanguage audioGuideLanguage;

  /// `+9779801234567` — how the number would be dialled from abroad.
  String get fullPhone => '$dialCode$phone';

  /// JSON-ready map. Once there is a real endpoint this is the exact body to
  /// send, so the screen code will not have to change when the API lands.
  Map<String, Object?> toJson() => <String, Object?>{
        'fullName': fullName,
        'address': address,
        'gender': gender.name,
        'nationalId': nationalId,
        'passportNumber': passportNumber,
        'phone': fullPhone,
        'email': email,
        'password': password,
        'country': country.iso,
        'audioGuideLanguage': audioGuideLanguage.code,
      };
}

/// The signed-in user as far as the rest of the app is concerned.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.completedOnboarding = false,
  });

  final String id;
  final String fullName;
  final String email;

  /// Drives whether login lands on `/home` or `/onboarding`. A brand-new account
  /// has not seen the intro carousel yet.
  final bool completedOnboarding;

  AuthUser copyWith({bool? completedOnboarding}) => AuthUser(
        id: id,
        fullName: fullName,
        email: email,
        completedOnboarding: completedOnboarding ?? this.completedOnboarding,
      );
}

/// Raised for anything a user should see a message about. The screens catch it
/// and surface [message]; everything else is treated as a bug.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Stand-in for the real auth API.
///
/// Every method takes and returns the same types the production client will, so
/// swapping the bodies for `dio` calls is a local change. The artificial delay
/// keeps the loading states honest during development.
///
/// One instance is shared app-wide via [AuthService.instance]; the constructor
/// is private so a test can still get a clean one.
class AuthService {
  AuthService();

  /// Shared instance. The account store below is per-instance state, so screens
  /// resolve their service through this rather than constructing their own.
  static final AuthService instance = AuthService();

  /// Latency of the fake round-trip.
  static const Duration latency = Duration(milliseconds: 900);

  /// Accounts created in this session, keyed by lowercase email. A real client
  /// would hold nothing here.
  final Map<String, _Account> _users = <String, _Account>{};

  /// The password every account is created with, so login can be exercised
  /// without a backend.
  static const String demoPassword = 'heritage123';

  /// Email used to pre-fill a known account during development.
  static const String demoEmail = 'visitor@nepalheritage.app';

  bool get hasSession => _users.isNotEmpty;

  AuthUser? get currentUser => _users.values.firstOrNull?.user;

  /// Creates an account and returns the new user. The returned user has
  /// `completedOnboarding: false`, which is what sends the caller to
  /// `/onboarding` rather than `/home`.
  Future<AuthUser> register(RegistrationRequest request) async {
    await Future<void>.delayed(latency);

    final String key = request.email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    if (request.nationalId.trim().toLowerCase() ==
        request.passportNumber.trim().toLowerCase()) {
      throw const AuthException(
        'National ID and passport number must be different.',
      );
    }
    if (request.password.length < minPasswordLength) {
      throw const AuthException(
        'Password must be at least 6 characters.',
      );
    }

    final AuthUser user = AuthUser(
      id: 'usr_${_users.length + 1}',
      fullName: request.fullName.trim(),
      email: request.email.trim(),
    );
    _users[key] = _Account(user: user, password: request.password);
    return user;
  }

  /// Signs in with an email *or* a phone number.
  ///
  /// An account created through [register] in this session signs in with the
  /// password it was created with. A new identifier is accepted and returned as
  /// a first-time user, so the onboarding branch is reachable without a
  /// fixture.
  Future<AuthUser> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(latency);

    final String id = identifier.trim();
    if (id.isEmpty) {
      throw const AuthException('Enter your email or phone number.');
    }
    if (password.length < minPasswordLength) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final String key = id.toLowerCase();
    final _Account? existing = _users[key];
    if (existing != null) {
      if (existing.password != password) {
        throw const AuthException('Incorrect password. Please try again.');
      }
      return existing.user;
    }

    if (key == demoEmail) {
      final AuthUser demo = AuthUser(
        id: 'usr_demo',
        fullName: 'Demo Visitor',
        email: demoEmail,
        completedOnboarding: true,
      );
      _users[key] = _Account(user: demo, password: password);
      return demo;
    }

    final AuthUser fresh = AuthUser(
      id: 'usr_${_users.length + 1}',
      fullName: _titleFromEmail(id),
      email: id.contains('@') ? id : '$key@pending.nepalheritage.app',
    );
    _users[key] = _Account(user: fresh, password: password);
    return fresh;
  }

  /// Sends a reset link. Always succeeds — there is nothing to verify against
  /// yet, and a failure here would only leak whether an account exists.
  Future<void> requestPasswordReset(String identifier) async {
    await Future<void>.delayed(latency);
    if (identifier.trim().isEmpty) {
      throw const AuthException('Enter your email or phone number.');
    }
  }

  /// Called once the intro carousel is finished, so later logins skip it.
  ///
  /// Matched on [AuthUser.id] rather than email: an account created by signing
  /// in with a phone number is stored under that number, not its email.
  AuthUser markOnboardingComplete(AuthUser user) {
    final AuthUser updated = user.copyWith(completedOnboarding: true);
    for (final String key in _users.keys.toList()) {
      if (_users[key]?.user.id == user.id) {
        _users[key] = _Account(user: updated, password: _users[key]!.password);
      }
    }
    return updated;
  }

  void signOut() => _users.clear();

  /// Best-effort display name for an account the app has not seen before.
  static String _titleFromEmail(String identifier) {
    final String local = identifier.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    if (local.isEmpty) {
      return 'Traveller';
    }
    return local
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .map((String part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

/// Shortest password the fake API accepts.
///
/// Shared by the service and the two form screens so the inline hint, the
/// validation message and the server-side rejection cannot drift apart.
const int minPasswordLength = 6;

/// A stored account: the user as the rest of the app sees it, plus the
/// credential [AuthService.login] has to check against.
class _Account {
  const _Account({required this.user, required this.password});

  final AuthUser user;
  final String password;
}
