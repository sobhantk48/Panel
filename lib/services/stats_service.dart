import 'package:dio/dio.dart';
import '../models/stats_model.dart';
import 'secure_storage_service.dart';

class StatsService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  StatsService(this._dio);

  Future<DashboardStats> fetchStats() async {
    final key = await _storage.getApiKey();
    final apiRoute = await _storage.getApiRoute() ?? 'sync';

    final response = await _dio.get(
      '/$apiRoute/api/stats',
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
