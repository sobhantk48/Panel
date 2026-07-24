import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stats_repository.dart';
import 'stats_state.dart';

class StatsNotifier extends StateNotifier<StatsState> {
  final StatsRepository _repository;

  StatsNotifier(this._repository) : super(const StatsState());

  Future<void> loadStats() async {
    state = state.copyWith(status: StatsStatus.loading);
    try {
      final stats = await _repository.getStats();
      state = state.copyWith(status: StatsStatus.success, stats: stats);
    } catch (e) {
      state = state.copyWith(
        status: StatsStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() => loadStats();
}
