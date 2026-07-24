import '../../../core/api/api_client.dart';
import 'stats_model.dart';

class StatsRepository {
  final ApiClient _client;

  StatsRepository(this._client);

  Future<StatsModel> getStats() async {
    final res = await _client.get('/api/stats');
    return StatsModel.fromJson(res.data as Map<String, dynamic>);
  }
}
