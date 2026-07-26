import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/logs_repository.dart';
import 'logs_state.dart';

class LogsNotifier extends StateNotifier<LogsState> {
  final LogsRepository _repository;

  LogsNotifier(this._repository) : super(const LogsState());

  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final logs = await _repository.getLogs();
      state = state.copyWith(isLoading: false, logs: logs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Alias برای سازگاری با اکشن Refresh در main_screen
  Future<void> refresh() => loadLogs();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setType(String type) {
    state = state.copyWith(selectedType: type);
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: '', selectedType: 'all');
  }
}
