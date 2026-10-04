import 'package:dio/dio.dart';

/// Build-time configuration for the real backend.
///
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000` points the
/// app at the API; with no define the in-memory mock stays in charge, so
/// tests and offline demo builds behave exactly as before.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get useMockApi => baseUrl.isEmpty;
}

/// Thin Dio wrapper the auth client talks through: one base URL, one bearer
/// token, timeouts that keep a hung request from pinning a spinner forever.
class ApiClient {
  ApiClient({required String baseUrl, Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: <String, String>{'Content-Type': 'application/json'},
              ),
            );

  final Dio dio;

  String? _token;

  /// Bearer token from the last register/login. In-memory only: a restart
  /// signs the user out, which is how the mock has always behaved too.
  String? get token => _token;

  set token(String? value) {
    _token = value;
    if (value == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $value';
    }
  }

  /// Shared client backing [ApiConfig]'s base URL. Tests inject their own.
  static final ApiClient instance = ApiClient(baseUrl: ApiConfig.baseUrl);
}
