import '../../../core/api/api_client.dart';
import 'api_key_model.dart';

class KeysRepository {
  final ApiClient _client;

  KeysRepository(this._client);

  /// GET /api/keys  → لیست کلیدها (کلید کامل برنمی‌گردد)
  Future<List<ApiKeyEntry>> getKeys() async {
    final res = await _client.get('/api/keys');
    final list = (res.data['keys'] as List?) ?? [];
    return list
        .map((e) => ApiKeyEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// POST /api/keys  با action=create → کلید کامل فقط همین یک بار برمی‌گردد
  Future<ApiKeyEntry> createKey(String name) async {
    final res = await _client.post('/api/keys', data: {
      'action': 'create',
      'name': name,
    });
    return ApiKeyEntry.fromJson(Map<String, dynamic>.from(res.data['key']));
  }

  /// POST /api/keys با action=revoke → باطل کردن کلید
  Future<void> revokeKey(String id) async {
    await _client.post('/api/keys', data: {
      'action': 'revoke',
      'id': id,
    });
  }
}
