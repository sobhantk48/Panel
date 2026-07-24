import '../data/stats_model.dart';

enum StatsStatus { initial, loading, loaded, error }

class StatsState {
  final StatsStatus status;
  final StatsModel? stats;
  final String? error;

  const StatsState({
    this.status = StatsStatus.initial,
    this.stats,
    this.error,
  });

  StatsState copyWith({
    StatsStatus? status,
    StatsModel? stats,
    String? error,
  }) {
    return StatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      error: error,
    );
  }
}
