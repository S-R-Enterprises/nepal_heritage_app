import 'package:dio/dio.dart';

import '../data/api_client.dart';
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

  /// JSON-ready map — the exact body `POST /api/v1/auth/register` takes.
  /// Dial code and local number stay separate, the way the form (and the
  /// server's `phoneE164` helper) holds them.
  Map<String, Object?> toJson() => <String, Object?>{
        'fullName': fullName,
        'address': address,
        'gender': gender.name,
        'nationalId': nationalId,
        'passportNumber': passportNumber,
        'dialCode': dialCode,
        'phone': phone,
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

/// Client for the auth API.
///
/// Built with `--dart-define=API_BASE_URL=...` it talks to the real backend
/// through Dio (`api/` in this repo); without the define it runs the
/// in-memory mock below, so tests and offline demo builds need no server.
/// Both modes share one code path for the session, so [currentUser],
/// [hasSession] and [signOut] behave identically either way.
///
/// One instance is shared app-wide via [AuthService.instance].
class AuthService {
  /// [useApi] and [api] exist for tests; production reads them from
  /// [ApiConfig] and the shared [ApiClient.instance].
  AuthService({bool? useApi, ApiClient? api})
      : _useApi = useApi ?? !ApiConfig.useMockApi,
        _client = api ?? ApiClient.instance;

  /// Shared instance. The account store below is per-instance state, so screens
  /// resolve their service through this rather than constructing their own.
  static final AuthService instance = AuthService();

  /// Latency of the fake round-trip (mock mode only).
  static const Duration latency = Duration(milliseconds: 900);

  /// The signed-in session: exactly one entry in API mode, whatever the mock
  /// has created so far in mock mode.
  final Map<String, _Account> _users = <String, _Account>{};

  final bool _useApi;
  final ApiClient _client;

  /// Fixture password used by tests and demo walkthroughs. It is not a
  /// credential: the mock accepts whatever password an account was created
  /// with, and there is no backend for it to protect.
  static const String demoPassword = 'heritage123';

  /// Email used to pre-fill a known account during development.
  static const String demoEmail = 'visitor@nepalheritage.app';

  bool get hasSession => _users.isNotEmpty;

  AuthUser? get currentUser => _users.values.firstOrNull?.user;

  /// Creates an account and returns the new user. The returned user has
  /// `completedOnboarding: false`, which is what sends the caller to
  /// `/onboarding` rather than `/home`.
  Future<AuthUser> register(RegistrationRequest request) async {
    if (_useApi) {
      return _registerViaApi(request);
    }

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
  /// In mock mode an account created through [register] in this session signs
  /// in with the password it was created with, and a new identifier is
  /// accepted as a first-time user so the onboarding branch is reachable
  /// without a fixture. In API mode the server answers with one message for
  /// both "no such account" and "wrong password".
  Future<AuthUser> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    final String id = identifier.trim();
    if (id.isEmpty) {
      throw const AuthException('Enter your email or phone number.');
    }
    if (password.length < minPasswordLength) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    if (_useApi) {
      return _loginViaApi(id, password, rememberMe);
    }

    await Future<void>.delayed(latency);

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
    if (identifier.trim().isEmpty) {
      throw const AuthException('Enter your email or phone number.');
    }

    if (_useApi) {
      try {
        await _client.dio.post<Object?>(
          '/api/v1/auth/reset-password',
          data: <String, Object?>{'identifier': identifier.trim()},
        );
      } on DioException catch (e) {
        throw _serverException(e);
      }
      return;
    }

    await Future<void>.delayed(latency);
  }

  /// Called once the intro carousel is finished, so later logins skip it.
  ///
  /// Matched on [AuthUser.id] rather than email: an account created by signing
  /// in with a phone number is stored under that number, not its email.
  Future<AuthUser> markOnboardingComplete(AuthUser user) async {
    if (_useApi) {
      try {
        final Response<Object?> res = await _client.dio.patch<Object?>(
          '/api/v1/me',
          data: <String, Object?>{'completedOnboarding': true},
        );
        final AuthUser updated = _userFromJson(_asJsonMap(_asJsonMap(res.data)['user']));
        _storeUser(updated);
        return updated;
      } on DioException catch (e) {
        throw _serverException(e);
      }
    }

    final AuthUser updated = user.copyWith(completedOnboarding: true);
    _storeUser(updated);
    return updated;
  }

  void signOut() {
    _users.clear();
    _client.token = null;
  }

  // ── API mode ───────────────────────────────────────────────────────────────

  Future<AuthUser> _registerViaApi(RegistrationRequest request) async {
    try {
      final Response<Object?> res = await _client.dio.post<Object?>(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
      return _openSession(
        res.data,
        key: request.email.trim().toLowerCase(),
        password: request.password,
      );
    } on DioException catch (e) {
      throw _serverException(e);
    }
  }

  Future<AuthUser> _loginViaApi(
    String id,
    String password,
    bool rememberMe,
  ) async {
    try {
      final Response<Object?> res = await _client.dio.post<Object?>(
        '/api/v1/auth/login',
        data: <String, Object?>{
          'identifier': id,
          'password': password,
          'rememberMe': rememberMe,
        },
      );
      return _openSession(
        res.data,
        key: id.toLowerCase(),
        password: password,
      );
    } on DioException catch (e) {
      throw _serverException(e);
    }
  }

  /// Reads `{user, token}` from an auth response and stores it exactly the
  /// way the mock stores an account, so the session getters and [signOut]
  /// work the same in both modes.
  AuthUser _openSession(
    Object? data, {
    required String key,
    required String password,
  }) {
    final Map<String, Object?> body = _asJsonMap(data);
    final AuthUser user = _userFromJson(_asJsonMap(body['user']));
    final Object? token = body['token'];
    if (token is! String) {
      throw const AuthException('Something went wrong. Please try again.');
    }
    _client.token = token;
    _users
      ..clear()
      ..[key] = _Account(user: user, password: password);
    return user;
  }

  /// Replaces the stored copy of [user] under whichever key it lives.
  void _storeUser(AuthUser user) {
    for (final String key in _users.keys.toList()) {
      if (_users[key]?.user.id == user.id) {
        _users[key] = _Account(user: user, password: _users[key]!.password);
      }
    }
  }

  /// Maps a failed API call onto the message the screens already display.
  /// Network-level failures never surface Dio internals to the user.
  AuthException _serverException(DioException e) {
    final Object? data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return AuthException(data['message']! as String);
    }
    if (e.response == null) {
      return const AuthException(
        'Cannot reach the server. Check your connection and try again.',
      );
    }
    return const AuthException('Something went wrong. Please try again.');
  }

  static Map<String, Object?> _asJsonMap(Object? value) {
    if (value is! Map) {
      throw const AuthException('Something went wrong. Please try again.');
    }
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> e in value.entries)
        e.key! as String: e.value,
    };
  }

  static AuthUser _userFromJson(Map<String, Object?> json) => AuthUser(
        id: json['id']! as String,
        fullName: json['fullName']! as String,
        email: json['email']! as String,
        completedOnboarding: json['completedOnboarding'] == true,
      );

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
