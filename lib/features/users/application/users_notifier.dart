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

  Future<void> refresh() => loadUsers();

  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      await _repo.createUser(data);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _repo.updateUser(id, data);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _repo.deleteUser(id);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// فعال/توقف کاربر. سرور فقط active و paused را می‌پذیرد.
  /// اگر [enable] پاس داده نشود، وضعیت فعلی برعکس می‌شود.
  Future<bool> toggleUser(String id, [bool? enable]) async {
    try {
      bool target;
      if (enable != null) {
        target = enable;
      } else {
        final idx = state.users.indexWhere((u) => u.id == id);
        target = idx == -1 ? true : state.users[idx].status != 'active';
      }
      await _repo.setStatus(id, target ? 'active' : 'paused');
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> resetUsage(String id) async {
    try {
      await _repo.resetUsage(id);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
