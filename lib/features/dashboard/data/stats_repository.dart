import '../../../core/api/api_client.dart';
import 'models/stats_model.dart';

class StatsRepository {
  final ApiClient _apiClient;

  StatsRepository(this._apiClient);

  Future<StatsModel> getStats() async {
    final response = await _apiClient.get('/api/stats');

    if (response is Map<String, dynamic> && response['success'] == true) {
      final statsJson = response['stats'] as Map<String, dynamic>? ?? {};
      return StatsModel.fromJson(statsJson);
    }

    throw Exception(response['error']?.toString() ?? 'خطا در دریافت آمار');
  }
}
