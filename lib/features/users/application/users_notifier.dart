import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/users_repository.dart';
import 'users_state.dart';

class UsersNotifier extends StateNotifier<UsersState> {
  final UsersRepository _repo;

  UsersNotifier(this._repo) : super(const UsersState());

  Future<void> loadUsers({String? query}) async {
    state = state.copyWith(status: UsersStatus.loading);
    try {
      final users = await _repo.getUsers(query: query);
      state = state.copyWith(status: UsersStatus.loaded, users: users);
    } catch (e) {
      state = state.copyWith(status: UsersStatus.error, error: e.toString());
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    return _mutate(() => _repo.createUser(data));
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    return _mutate(() => _repo.updateUser(id, data));
  }

  Future<bool> deleteUser(String id) async {
    return _mutate(() => _repo.deleteUser(id));
  }

  /// فعال / متوقف کردن کاربر
  Future<bool> toggleUser(String id) async {
    return _mutate(() => _repo.toggleUser(id));
  }

  /// بازنشانی مصرف (reqs و dReqs)
  Future<bool> resetTraffic(String id) async {
    return _mutate(() => _repo.resetTraffic(id));
  }

  /// اجرای یک عملیات نوشتنی، سپس تازه‌سازی لیست.
  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      await action();
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(status: UsersStatus.error, error: e.toString());
      return false;
    }
  }
}
