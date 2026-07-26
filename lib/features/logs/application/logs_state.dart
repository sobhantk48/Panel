import '../data/log_model.dart';

class LogsState {
  final bool isLoading;
  final List<LogEntry> logs;
  final String? error;
  final String searchQuery;
  final String selectedType;

  const LogsState({
    this.isLoading = false,
    this.logs = const [],
    this.error,
    this.searchQuery = '',
    this.selectedType = 'all',
  });

  List<String> get availableTypes {
    final set = <String>{for (final l in logs) l.type};
    final list = set.toList()..sort();
    return ['all', ...list];
  }

  List<LogEntry> get filteredLogs {
    final q = searchQuery.trim().toLowerCase();
    return logs.where((l) {
      final matchType = selectedType == 'all' || l.type == selectedType;
      final matchQuery = q.isEmpty ||
          l.type.toLowerCase().contains(q) ||
          l.detail.toLowerCase().contains(q);
      return matchType && matchQuery;
    }).toList();
  }

  LogsState copyWith({
    bool? isLoading,
    List<LogEntry>? logs,
    String? error,
    bool clearError = false,
    String? searchQuery,
    String? selectedType,
  }) {
    return LogsState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}
