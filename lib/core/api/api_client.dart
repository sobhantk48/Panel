import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    _dio = Dio();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final key = await _storage.read(key: ApiConstants.keyApiKey);
        if (key != null) {
          options.headers['Authorization'] = 'Bearer $key';
        }
        handler.next(options);
      },
    ));
  }

  Future<String> _baseUrl() async {
    final base = await _storage.read(key: ApiConstants.keyBaseUrl) ?? '';
    final route = await _storage.read(key: ApiConstants.keyApiRoute) ?? ApiConstants.defaultApiRoute;
    return '$base$route';
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get('${await _baseUrl()}$path', queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post('${await _baseUrl()}$path', data: data);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.put('${await _baseUrl()}$path', data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.delete('${await _baseUrl()}$path', queryParameters: queryParameters);
  }

  // برای auth
  Future<Response> postAuth(String baseUrl, String apiRoute, Map<String, dynamic> data) async {
    return _dio.post('$baseUrl$apiRoute/api/auth', data: data);
  }
}
