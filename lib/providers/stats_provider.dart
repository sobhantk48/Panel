import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/stats_model.dart';
import '../services/stats_service.dart';
import 'api_provider.dart';

class StatsNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final StatsService _service;

  StatsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _service.fetchStats();
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final statsServiceProvider = Provider<StatsService>((ref) {
  final dio = ref.watch(dioProvider);
  return StatsService(dio);
});

final statsProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<DashboardStats>>((ref) {
  final service = ref.watch(statsServiceProvider);
  return StatsNotifier(service);
});
