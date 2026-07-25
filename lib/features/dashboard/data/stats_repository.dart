import '../../../core/api/api_client.dart';
import 'models/stats_model.dart';

class StatsRepository {
  final ApiClient _apiClient;

  StatsRepository(this._apiClient);

  Future<StatsModel> getStats() async {
    final response = await _apiClient.get('/api/stats');
    final data = response.data as Map<String, dynamic>;

    if (data['success'] == true) {
      return StatsModel.fromJson(data['stats'] as Map<String, dynamic>? ?? {});
    }

    throw Exception(data['error']?.toString() ?? 'خطا در دریافت آمار');
  }
}
