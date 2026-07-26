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

  Future<bool> toggleUser(String id) async {
    try {
      await _repo.toggleUser(id);
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
