import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../application/stats_state.dart';
import '../data/models/stats_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(statsNotifierProvider.notifier).loadStats(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statsNotifierProvider);
    final isRefreshing =
        state.status == StatsStatus.loading && state.stats != null;

    return Column(
      children: [
        if (isRefreshing) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(statsNotifierProvider.notifier).refresh(),
            child: _buildBody(state),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(StatsState state) {
    switch (state.status) {
      case StatsStatus.initial:
      case StatsStatus.loading:
        if (state.stats == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(state.stats!);

      case StatsStatus.error:
        if (state.stats != null) return _buildContent(state.stats!);
        return ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Center(
              child: Text(
                state.errorMessage ?? 'خطای نامشخص',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton.icon(
                onPressed: () =>
                    ref.read(statsNotifierProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش مجدد'),
              ),
            ),
          ],
        );

      case StatsStatus.success:
        return _buildContent(state.stats!);
    }
  }

  Widget _buildContent(StatsModel stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSystemCard(stats.system),
        const SizedBox(height: 16),
        _buildUsersCard(stats.users),
        const SizedBox(height: 16),
        _buildTrafficCard(stats.traffic),
        const SizedBox(height: 16),
        if (stats.usage.isNotEmpty) _buildUsageCard(stats.usage),
      ],
    );
  }

  Widget _buildSystemCard(SystemStats system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  system.isPaused ? Icons.pause_circle : Icons.check_circle,
                  color: system.isPaused ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  system.isPaused ? 'متوقف شده' : 'فعال',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  'نسخه ${system.version}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow('مدت فعالیت', system.uptimeFormatted),
            _infoRow('اتصالات فعال', '${system.activeConnections}'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersCard(UsersStats users) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'کاربران',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statBox('کل', users.total, Colors.blue),
                _statBox('فعال', users.active, Colors.green),
                _statBox('متوقف', users.paused, Colors.orange),
                _statBox('منقضی', users.expired, Colors.red),
                _statBox('غیرفعال خودکار', users.autoDisabled, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficCard(TrafficStats traffic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترافیک',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 24),
            _infoRow('کل درخواست‌ها', '${traffic.totalRequests}'),
            _infoRow('کل حجم', '${traffic.totalGB.toStringAsFixed(2)} GB'),
            _infoRow('درخواست امروز', '${traffic.dailyRequests}'),
            _infoRow('حجم امروز', '${traffic.dailyGB.toStringAsFixed(2)} GB'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(List<UsageEntry> usage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اتصالات کاربران',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 24),
            ...usage.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Chip(label: Text('${e.connects} اتصال')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statBox(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
