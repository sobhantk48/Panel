import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../data/keys_repository.dart';
import 'keys_notifier.dart';
import 'keys_state.dart';

final keysRepositoryProvider = Provider<KeysRepository>((ref) {
  return KeysRepository(ref.watch(apiClientProvider));
});

final keysNotifierProvider =
    StateNotifierProvider<KeysNotifier, KeysState>((ref) {
  return KeysNotifier(ref.watch(keysRepositoryProvider));
});
