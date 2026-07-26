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
    final res =
        await _client.get('/api/users', queryParameters: {'id': idOrName});
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

  Future<void> deleteUser(String id) async {
    await _client.delete('/api/users', queryParameters: {'id': id});
  }

  /// فعال/غیرفعال کردن کاربر از طریق همان PUT /api/users
  Future<NahanUser> setStatus(String id, String status) {
    return updateUser(id, {'status': status});
  }

  /// ریست مصرف کاربر
  Future<NahanUser> resetUsage(String id) {
    return updateUser(id, {'reset_usage': true});
  }
}
