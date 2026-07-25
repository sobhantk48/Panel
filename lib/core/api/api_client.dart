import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
        // پاسخ رشته‌ای هم می‌گیریم تا خودمون پارس کنیم
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final key = await _storage.getApiKey();
        if (key != null) {
          options.headers['Authorization'] = 'Bearer $key';
        }
        if (kDebugMode) {
          debugPrint('➡️ ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('⬅️ ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
    ));
  }

  // حذف اسلش‌های اضافه از دو سر یک قطعه
  String _clean(String? s) =>
      (s ?? '').trim().replaceAll(RegExp(r'^/+|/+$'), '');

  // چسباندن قطعات URL با یک اسلش تمیز
  String _join(List<String> parts) {
    final base = parts.first.trim().replaceAll(RegExp(r'/+$'), '');
    final rest = parts.skip(1).map(_clean).where((e) => e.isNotEmpty);
    return [base, ...rest].join('/');
  }

  Future<String> _baseUrl() async {
    final base = await _storage.getBaseUrl() ?? '';
    final route = await _storage.getApiRoute() ?? ApiConstants.defaultApiRoute;
    return _join([base, route]);
  }

  // retry ساده روی خطای شبکه (DNS flaky روی موبایل‌دیتا)
  Future<Response> _retry(Future<Response> Function() run) async {
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        return await run();
      } on DioException catch (e) {
        final isNetwork = e.error is SocketException ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout;
        if (isNetwork && attempt < 3) {
          if (kDebugMode) debugPrint('🔁 retry شبکه ($attempt) ...');
          await Future.delayed(Duration(milliseconds: 400 * attempt));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('unreachable');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _retry(() async => _dio.get(
          _join([await _baseUrl(), path]),
          queryParameters: queryParameters,
        ));
  }

  Future<Response> post(String path, {dynamic data}) {
    return _retry(() async => _dio.post(
          _join([await _baseUrl(), path]),
          data: data,
        ));
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _retry(() async => _dio.put(
          _join([await _baseUrl(), path]),
          data: data,
          queryParameters: queryParameters,
        ));
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters}) {
    return _retry(() async => _dio.delete(
          _join([await _baseUrl(), path]),
          queryParameters: queryParameters,
        ));
  }

  Future<AuthResponse> login({
    required String baseUrl,
    required String apiRoute,
    required String key,
  }) async {
    final url = _join([baseUrl, apiRoute, 'api', 'auth']);

    final response = await _retry(() => _dio.post(url, data: {'key': key}));

    final data = _asJson(response.data);

    if (data['success'] == true) {
      await _storage.saveCredentials(
        baseUrl: baseUrl.trim().replaceAll(RegExp(r'/+$'), ''),
        apiKey: key,
        apiRoute: _clean(apiRoute),
      );
      return AuthResponse.fromJson(data);
    }
    throw Exception(data['error']?.toString() ?? 'خطا در احراز هویت');
  }

  // پارسر مقاوم: اگر رشته خام بود، به Map تبدیلش کن
  Map<String, dynamic> _asJson(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      final text = raw.trim();
      if (text.startsWith('{') || text.startsWith('[')) {
        final decoded = _tryDecode(text);
        if (decoded is Map<String, dynamic>) return decoded;
      }
      throw Exception(
          'پاسخ سرور JSON نبود (احتمالاً صفحه HTML). پیش‌نمایش: '
          '${text.substring(0, text.length > 120 ? 120 : text.length)}');
    }
    throw Exception('نوع پاسخ نامعتبر: ${raw.runtimeType}');
  }

  dynamic _tryDecode(String text) {
    try {
      // ignore: unnecessary_this
      return const JsonCodec().decode(text);
    } catch (_) {
      return null;
    }
  }
}
