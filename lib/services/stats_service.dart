import 'package:dio/dio.dart';
import '../models/stats_model.dart';
import 'secure_storage_service.dart';

class StatsService {
  final Dio _dio;

  StatsService(this._dio);

  Future<DashboardStats> fetchStats() async {
    final key = await SecureStorageService.getApiKey();

    final response = await _dio.get(
      '/api/stats',
      options: Options(
        headers: {
          'Authorization': 'Bearer $key',
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['error']?.toString() ?? 'خطا در دریافت آمار');
    }

    return DashboardStats.fromJson(data['stats'] as Map<String, dynamic>);
  }
}
