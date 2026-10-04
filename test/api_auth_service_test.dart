import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_np/data/api_client.dart';
import 'package:nepal_np/data/auth_service.dart';
import 'package:nepal_np/data/country_data.dart';
import 'package:nepal_np/data/language_data.dart';

typedef _Respond = void Function(
  RequestOptions options,
  RequestInterceptorHandler handler,
);

/// Answers every request with a canned response and records what was sent,
/// so the seam can be tested without a server (or network) running.
class _FakeBackend extends Interceptor {
  _FakeBackend(this.respond);

  final _Respond respond;
  final List<RequestOptions> calls = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    calls.add(options);
    respond(options, handler);
  }
}

RegistrationRequest registrationRequest({String email = 'prabika@example.com'}) =>
    RegistrationRequest(
      fullName: 'Prabika Rai',
      address: 'Pokhara',
      gender: Gender.female,
      nationalId: '1234567890',
      passportNumber: '',
      dialCode: Countries.nepal.dialCode,
      phone: '9801234567',
      email: email,
      password: AuthService.demoPassword,
      country: Countries.nepal,
      audioGuideLanguage: AudioGuideLanguages.nepali,
    );

Map<String, Object?> userJson({
  String id = 'usr_1',
  String fullName = 'Prabika Rai',
  String email = 'prabika@example.com',
  bool completedOnboarding = false,
}) =>
    <String, Object?>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'completedOnboarding': completedOnboarding,
    };

Map<String, Object?> authResponse({bool completedOnboarding = false}) =>
    <String, Object?>{
      'user': userJson(completedOnboarding: completedOnboarding),
      'token': 'tok-1',
    };

void main() {
  late _FakeBackend backend;
  late ApiClient api;
  late AuthService auth;

  /// Wires a service in API mode against a fake HTTP layer.
  AuthService wire(_Respond respond) {
    backend = _FakeBackend(respond);
    api = ApiClient(baseUrl: 'http://api.test')
      ..dio.interceptors.add(backend);
    return AuthService(useApi: true, api: api);
  }

  void resolve(RequestOptions o, RequestInterceptorHandler h,
          {int status = 200, Object? data}) =>
      h.resolve(
        Response<Object?>(requestOptions: o, statusCode: status, data: data),
      );

  void rejectWithMessage(
    RequestOptions o,
    RequestInterceptorHandler h, {
    required int status,
    required String message,
    String code = 'error',
  }) =>
      h.reject(
        DioException(
          requestOptions: o,
          type: DioExceptionType.badResponse,
          response: Response<Object?>(
            requestOptions: o,
            statusCode: status,
            data: <String, Object?>{'error': code, 'message': message},
          ),
        ),
      );

  group('mode selection', () {
    test('no --dart-define keeps the mock in charge', () {
      expect(ApiConfig.useMockApi, isTrue);
    });

    test('the default service instance runs the mock', () async {
      final AuthUser user = await AuthService.instance.login(
        identifier: 'prabika.rai@example.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(user.fullName, 'Prabika Rai');
      AuthService.instance.signOut();
    });
  });

  group('API mode', () {
    test('register posts the form body and opens the session', () async {
      auth = wire((o, h) =>
          resolve(o, h, status: 201, data: authResponse()));

      final RegistrationRequest request = registrationRequest();
      final AuthUser user = await auth.register(request);

      expect(backend.calls.single.method, 'POST');
      expect(backend.calls.single.path, '/api/v1/auth/register');
      expect(backend.calls.single.data, request.toJson());
      expect(user.completedOnboarding, isFalse);
      expect(auth.hasSession, isTrue);
      expect(auth.currentUser?.id, 'usr_1');
      expect(api.token, 'tok-1');
    });

    test('register surfaces the server message verbatim', () async {
      auth = wire((o, h) => rejectWithMessage(
            o,
            h,
            status: 409,
            code: 'email_exists',
            message: 'An account with this email already exists.',
          ));

      expect(
        () => auth.register(registrationRequest()),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'An account with this email already exists.',
          ),
        ),
      );
      expect(auth.hasSession, isFalse);
    });

    test('login posts identifier, password and rememberMe', () async {
      auth = wire((o, h) => resolve(o, h, data: authResponse()));

      final AuthUser user = await auth.login(
        identifier: '  prabika@example.com  ',
        password: AuthService.demoPassword,
        rememberMe: true,
      );

      expect(backend.calls.single.path, '/api/v1/auth/login');
      expect(backend.calls.single.data, <String, Object?>{
        'identifier': 'prabika@example.com',
        'password': AuthService.demoPassword,
        'rememberMe': true,
      });
      expect(user.id, 'usr_1');
      expect(auth.currentUser, isNotNull);
      expect(api.token, 'tok-1');
    });

    test('a rejected login shows the one message the server sends', () async {
      auth = wire((o, h) => rejectWithMessage(
            o,
            h,
            status: 401,
            code: 'invalid_credentials',
            message: 'Incorrect email/phone or password.',
          ));

      expect(
        () => auth.login(
          identifier: 'prabika@example.com',
          password: AuthService.demoPassword,
          rememberMe: false,
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Incorrect email/phone or password.',
          ),
        ),
      );
      expect(auth.hasSession, isFalse);
    });

    test('an unreachable server fails with a friendly message', () async {
      auth = wire((o, h) => h.reject(
            DioException.connectionError(requestOptions: o, reason: 'offline'),
          ));

      expect(
        () => auth.login(
          identifier: 'prabika@example.com',
          password: AuthService.demoPassword,
          rememberMe: false,
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('Cannot reach the server'),
          ),
        ),
      );
    });

    test('local validation still answers before any request is sent', () async {
      auth = wire((o, h) => resolve(o, h));

      expect(
        () => auth.login(identifier: '  ', password: 'x', rememberMe: false),
        throwsA(isA<AuthException>()),
      );
      expect(
        () => auth.requestPasswordReset('   '),
        throwsA(isA<AuthException>()),
      );
      expect(backend.calls, isEmpty);
    });

    test('password reset posts the identifier', () async {
      auth = wire((o, h) =>
          resolve(o, h, status: 202, data: <String, Object?>{
            'message': 'If an account exists, a reset link has been sent.',
          }));

      await auth.requestPasswordReset('prabika@example.com');

      expect(backend.calls.single.path, '/api/v1/auth/reset-password');
      expect(backend.calls.single.data,
          <String, Object?>{'identifier': 'prabika@example.com'});
    });

    test('marking onboarding complete PATCHes /me and updates the session',
        () async {
      auth = wire((o, h) {
        if (o.method == 'PATCH') {
          resolve(o, h, data: <String, Object?>{
            'user': userJson(completedOnboarding: true),
          });
        } else {
          resolve(o, h, data: authResponse());
        }
      });

      final AuthUser first = await auth.login(
        identifier: 'prabika@example.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      final AuthUser updated = await auth.markOnboardingComplete(first);

      expect(updated.completedOnboarding, isTrue);
      expect(backend.calls.last.method, 'PATCH');
      expect(backend.calls.last.path, '/api/v1/me');
      expect(backend.calls.last.data, <String, Object?>{
        'completedOnboarding': true,
      });
      expect(auth.currentUser?.completedOnboarding, isTrue);
    });

    test('signing out drops the session and the bearer token', () async {
      auth = wire((o, h) => resolve(o, h, data: authResponse()));

      await auth.login(
        identifier: 'prabika@example.com',
        password: AuthService.demoPassword,
        rememberMe: false,
      );
      expect(api.token, 'tok-1');

      auth.signOut();
      expect(auth.hasSession, isFalse);
      expect(auth.currentUser, isNull);
      expect(api.token, isNull);
    });
  });
}
