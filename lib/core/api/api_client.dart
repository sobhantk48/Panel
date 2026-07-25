import 'package:dio/dio.dart';
import 'package:panel/core/storage/secure_storage_service.dart';
import 'api_constants.dart';
import 'models/auth_response.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final key = await _storage.getApiKey();
        if (key != null) {
          options.headers['Authorization'] = 'Bearer $key';
        }
        handler.next(options);
      },
    ));
  }

  // اسلش‌های اضافه‌ی ابتدا/انتها را حذف و یک URL تمیز می‌سازد
  String _join(String base, String route) {
    final b = base.replaceAll(RegExp(r'/+$'), '');
    final r = route.replaceAll(RegExp(r'^/+|/+$'), '');
    return r.isEmpty ? b : '$b/$r';
  }

  Future<String> _baseUrl() async {
    final base = await _storage.getBaseUrl() ?? '';
    final route =
        await _storage.getApiRoute() ?? ApiConstants.defaultApiRoute;
    return _join(base, route);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      '${await _baseUrl()}$path',
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post('${await _baseUrl()}$path', data: data);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put(
      '${await _baseUrl()}$path',
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete(
      '${await _baseUrl()}$path',
      queryParameters: queryParameters,
    );
  }

  Future<AuthResponse> login({
    required String baseUrl,
    required String apiRoute,
    required String key,
  }) async {
    final url = '${_join(baseUrl, apiRoute)}/api/auth';

    final response = await _dio.post(url, data: {'key': key});

    final data = response.data as Map<String, dynamic>;

    if (data['success'] == true) {
      await _storage.saveCredentials(
        baseUrl: baseUrl,
        apiKey: key,
        apiRoute: apiRoute,
      );
      return AuthResponse.fromJson(data);
    }

    throw Exception(data['error']?.toString() ?? 'خطا در احراز هویت');
  }
}
