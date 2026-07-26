import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/keys_repository.dart';
import 'keys_state.dart';

class KeysNotifier extends StateNotifier<KeysState> {
  final KeysRepository _repo;

  KeysNotifier(this._repo) : super(const KeysState());

  Future<void> loadKeys() async {
    state = state.copyWith(status: KeysStatus.loading, clearError: true);
    try {
      final keys = await _repo.getKeys();
      state = state.copyWith(status: KeysStatus.loaded, keys: keys);
    } catch (e) {
      state = state.copyWith(status: KeysStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() => loadKeys();

  Future<bool> createKey(String name) async {
    try {
      final created = await _repo.createKey(name);
      state = state.copyWith(newlyCreated: created);
      await loadKeys();
      return true;
    } catch (e) {
      state = state.copyWith(status: KeysStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> revokeKey(String id) async {
    try {
      await _repo.revokeKey(id);
      await loadKeys();
      return true;
    } catch (e) {
      state = state.copyWith(status: KeysStatus.error, error: e.toString());
      return false;
    }
  }

  void clearNewlyCreated() {
    state = state.copyWith(clearNewlyCreated: true);
  }
}
