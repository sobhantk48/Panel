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
        // اجازه می‌دهیم خودمان status را بررسی کنیم تا 404/401 exception پرت نکند
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final key = await _storage.getApiKey();

          if (key != null) {
            options.headers['Authorization'] = 'Bearer $key';
          }

          handler.next(options);
        },
      ),
    );
  }

  /// حذف اسلش‌های اضافی ابتدا و انتها
  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'^/+|/+\$'), '');
  }

  /// ساخت URL تمیز از اجزای مسیر
  String _buildUrl(String base, List<String> parts) {
    final cleanBase = base.trim().replaceAll(RegExp(r'/+\$'), '');
    final cleanParts = parts
        .map(_normalize)
        .where((p) => p.isNotEmpty)
        .join('/');

    return '$cleanBase/$cleanParts';
  }

  Future<String> _baseUrl() async {
    final base = await _storage.getBaseUrl() ?? '';
    final route =
        await _storage.getApiRoute() ?? ApiConstants.defaultApiRoute;

    return _buildUrl(base, [route]);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      _buildUrl(await _baseUrl(), [path]),
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return _dio.post(
      _buildUrl(await _baseUrl(), [path]),
      data: data,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put(
      _buildUrl(await _baseUrl(), [path]),
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete(
      _buildUrl(await _baseUrl(), [path]),
      queryParameters: queryParameters,
    );
  }

  Future<AuthResponse> login({
    required String baseUrl,
    required String apiRoute,
    required String key,
  }) async {
    final url = _buildUrl(baseUrl, [apiRoute, 'api', 'auth']);

    final response = await _dio.post(
      url,
      data: {'key': key},
    );

    // اگر پاسخ اصلاً JSON نبود (مثلاً صفحه 404 یا maintenance با متن/HTML)
    if (response.data is! Map) {
      if (response.statusCode == 404) {
        throw Exception(
          'مسیر API اشتباه است (404). مقدار «مسیر API» را با apiRoute واقعی ورکر مطابقت بده.',
        );
      }

      throw Exception(
        'پاسخ نامعتبر از سرور (کد ${response.statusCode}). آدرس ورکر و مسیر API را بررسی کن.',
      );
    }

    final data = Map<String, dynamic>.from(response.data as Map);

    if (data['success'] == true) {
      await _storage.saveCredentials(
        baseUrl: baseUrl,
        apiKey: key,
        apiRoute: apiRoute,
      );

      return AuthResponse.fromJson(data);
    }

    // کلید نامعتبر: ورکر {"success": false} با کد 401 برمی‌گرداند
    throw Exception(
      data['error']?.toString() ??
          (response.statusCode == 401
              ? 'کلید نامعتبر است'
              : 'خطا در احراز هویت'),
    );
  }
}
