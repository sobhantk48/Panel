import '../../../core/api/api_client.dart';
import 'user_model.dart';

class UsersRepository {
  final ApiClient _client;

  UsersRepository(this._client);

  Future<List<NahanUser>> getUsers({String? query}) async {
    final params = <String, dynamic>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    final res = await _client.get('/api/users', queryParameters: params);
    final list = res.data['users'] as List;
    return list.map((e) => NahanUser.fromJson(e)).toList();
  }

  Future<NahanUser> getUser(String idOrName) async {
    final res = await _client.get(
      '/api/users',
      queryParameters: {'id': idOrName},
    );
    return NahanUser.fromJson(res.data['user']);
  }

  Future<NahanUser> createUser(Map<String, dynamic> data) async {
    final res = await _client.post('/api/users', data: data);
    return NahanUser.fromJson(res.data['user']);
  }

  Future<NahanUser> updateUser(String id, Map<String, dynamic> data) async {
    final res = await _client.put(
      '/api/users',
      data: data,
      queryParameters: {'id': id},
    );
    return NahanUser.fromJson(res.data['user']);
  }

  /// DELETE /api/users?id=<id>
  /// پاسخ: {"success": true, "deleted": "<id>"}
  Future<void> deleteUser(String id) async {
    await _client.delete('/api/users', queryParameters: {'id': id});
  }

  /// POST /api/users?id=<id>&action=toggle
  /// مقدار isPaused را معکوس می‌کند و کاربر به‌روزشده را برمی‌گرداند.
  Future<NahanUser> toggleUser(String id) async {
    final res = await _client.post(
      '/api/users',
      queryParameters: {'id': id, 'action': 'toggle'},
    );
    return NahanUser.fromJson(res.data['user']);
  }

  /// POST /api/users?id=<id>&action=reset
  /// reqs و dReqs را صفر می‌کند. پاسخ فقط پیام است، بدون شیء user.
  Future<void> resetTraffic(String id) async {
    await _client.post(
      '/api/users',
      queryParameters: {'id': id, 'action': 'reset'},
    );
  }
}
