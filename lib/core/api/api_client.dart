import 'dart:convert';
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
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        // هر status code رو خودمون هندل می‌کنیم تا Dio روی 4xx/5xx throw نکنه
        validateStatus: (_) => true,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final key = await _storage.getApiKey();
          if (key != null && key.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $key';
          }
          handler.next(options);
        },
      ),
    );
  }

  // حذف اسلش‌های ابتدا و انتها
  String _clean(String s) =>
      s.trim().replaceAll(RegExp(r'^/+'), '').replaceAll(RegExp(r'/+$'), '');

  // چسباندن قطعات URL بدون اسلش اضافه
  String _join(List<String> parts) {
    final cleaned = parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map(_clean)
        .where((p) => p.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) return '';
    return cleaned.join('/');
  }

  Future<String> _baseUrl() async {
    final base = await _storage.getBaseUrl() ?? '';
    final route =
        await _storage.getApiRoute() ?? ApiConstants.defaultApiRoute;
    return _join([base, route]);
  }

  // پاسخ رو به Map تبدیل می‌کنه.
  // اگه Dio بادی رو به‌صورت String برگردونده باشه، خودمون jsonDecode می‌کنیم.
  Map<String, dynamic> _asJson(Response response, String url) {
    final data = response.data;

    // حالت اول: از قبل Map هست
    if (data is Map<String, dynamic>) return data;

    // حالت دوم: رشته‌ست، شاید JSON خام باشه
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {
          // decode نشد، می‌افته پایین به خطا
        }
      }
    }

    final status = response.statusCode ?? 0;
    final preview = data.toString();
    final shortPreview =
        preview.length > 120 ? '${preview.substring(0, 120)}...' : preview;

    throw Exception(
      'پاسخ نامعتبر از سرور (status $status).\n'
      'URL: $url\n'
      'به‌جای JSON این دریافت شد: $shortPreview',
    );
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final url = '${await _baseUrl()}$path';
    return _dio.get(url, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    final url = '${await _baseUrl()}$path';
    return _dio.post(url, data: data);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final url = '${await _baseUrl()}$path';
    return _dio.put(url, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final url = '${await _baseUrl()}$path';
    return _dio.delete(url, queryParameters: queryParameters);
  }

  Future<AuthResponse> login({
    required String baseUrl,
    required String apiRoute,
    required String key,
  }) async {
    final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final cleanRoute = _clean(apiRoute);
    final url = '$cleanBase/$cleanRoute/api/auth';

    final response = await _dio.post(
      url,
      data: {'key': key},
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );

    final status = response.statusCode ?? 0;

    if (status == 404) {
      throw Exception(
        'خطای 404: مسیر پیدا نشد.\n'
        'مقدار «مسیر API» احتمالاً اشتباهه.\n'
        'URL درخواست: $url',
      );
    }

    final data = _asJson(response, url);

    if (data['success'] == true) {
      await _storage.saveCredentials(
        baseUrl: cleanBase,
        apiKey: key,
        apiRoute: cleanRoute,
      );
      return AuthResponse.fromJson(data);
    }

    throw Exception(
      data['error']?.toString() ??
          'خطا در احراز هویت (status $status)\nURL: $url',
    );
  }
}
