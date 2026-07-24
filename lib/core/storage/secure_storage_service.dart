import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _kBaseUrl = 'base_url';
  static const _kApiKey = 'api_key';
  static const _kApiRoute = 'api_route';

  Future<void> saveCredentials({
    required String baseUrl,
    required String apiKey,
    required String apiRoute,
  }) async {
    await _storage.write(key: _kBaseUrl, value: baseUrl);
    await _storage.write(key: _kApiKey, value: apiKey);
    await _storage.write(key: _kApiRoute, value: apiRoute);
  }

  Future<String?> getBaseUrl() => _storage.read(key: _kBaseUrl);
  Future<String?> getApiKey() => _storage.read(key: _kApiKey);
  Future<String?> getApiRoute() => _storage.read(key: _kApiRoute);

  Future<bool> hasCredentials() async {
    final baseUrl = await getBaseUrl();
    final apiKey = await getApiKey();
    return baseUrl != null && baseUrl.isNotEmpty && apiKey != null && apiKey.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
