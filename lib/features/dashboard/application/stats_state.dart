import '../data/models/stats_model.dart';

enum StatsStatus { initial, loading, success, error }

class StatsState {
  final StatsStatus status;
  final StatsModel? stats;
  final String? errorMessage;

  const StatsState({
    this.status = StatsStatus.initial,
    this.stats,
    this.errorMessage,
  });

  StatsState copyWith({
    StatsStatus? status,
    StatsModel? stats,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }
}
