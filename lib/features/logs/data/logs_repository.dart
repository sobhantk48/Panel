import '../../../core/api/api_client.dart';
import 'log_model.dart';

class LogsRepository {
  final ApiClient _client;

  LogsRepository(this._client);

  Future<List<LogEntry>> getLogs() async {
    final res = await _client.post('/api/logs', data: {});
    final data = res.data;
    if (data is Map && data['logs'] is List) {
      return (data['logs'] as List)
          .whereType<Map>()
          .map((e) => LogEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <LogEntry>[];
  }
}
