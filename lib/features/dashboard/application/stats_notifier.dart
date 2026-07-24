import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stats_repository.dart';
import 'stats_state.dart';

class StatsNotifier extends StateNotifier<StatsState> {
  final StatsRepository _repo;

  StatsNotifier(this._repo) : super(const StatsState());

  Future<void> loadStats() async {
    state = state.copyWith(status: StatsStatus.loading);
    try {
      final stats = await _repo.getStats();
      state = state.copyWith(status: StatsStatus.loaded, stats: stats);
    } catch (e) {
      state = state.copyWith(status: StatsStatus.error, error: e.toString());
    }
  }
}
