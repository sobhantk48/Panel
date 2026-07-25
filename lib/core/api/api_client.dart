import 'package:dio/dio.dart';
import 'package:panel/core/storage/secure_storage_service.dart';
import 'api_constants.dart';
import 'models/auth_response.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        validateStatus: (status) => status != null && status < 600,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

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

  String _clean(String s) =>
      s.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  String _join(String base, List<String> parts) {
    final b = base.trim().replaceAll(RegExp(r'/+$'), '');
    final p = parts.map(_clean).where((x) => x.isNotEmpty).join('/');
    return '$b/$p';
  }

  Future<String> _baseUrl() async {
    final base = await _storage.getBaseUrl() ?? '';
    final route = await _storage.getApiRoute()??
        ApiConstants.defaultApiRoute;
    return _join(base, [route]);
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(_join(await _baseUrl(), [path]),
        queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(_join(await _baseUrl(), [path]), data: data);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.put(_join(await _baseUrl(), [path]),
        data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _dio.delete(_join(await _baseUrl(), [path]),
        queryParameters: queryParameters);
  }

  Future<AuthResponse> login({
    required String baseUrl,
    required String apiRoute,
    required String key,
  }) async {
    final url = _join(baseUrl, [apiRoute, 'api', 'auth']);

    Response response;
    try {
      response = await _dio.post(url, data: {'key': key});
    } on DioException catch (e) {
      throw Exception('خطای شبکه: ${e.message}');
    }

    // اگه JSON نبود → صفحه maintenance یا HTML است
    // یعنی apiRoute اشتباه است
    if (response.data is! Map) {
      throw Exception('ورکر صفحه maintenance برگرداند (کد ${response.statusCode}).\n'
        'URL: $url\n'
        'apiRoute شما ($apiRoute) با تنظیمات ورکر مطابقت ندارد.',
      );
    }

    final data = Map<String, dynamic>.from(response.data as Map);

    if (response.statusCode == 404) {
      throw Exception('مسیر یافت نشد (404).\nURL: $url');
    }

    if (data['success'] == true) {
      await _storage.saveCredentials(
        baseUrl: baseUrl,
        apiKey: key,
        apiRoute: apiRoute,
      );
      return AuthResponse.fromJson(data);
    }

    throw Exception(
      data['error']?.toString() ??
          (response.statusCode == 401
              ? 'کلید نامعتبر است'
              : 'خطا در احراز هویت (${response.statusCode})'),
    );
  }
}
