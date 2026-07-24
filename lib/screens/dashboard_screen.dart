import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(statsProvider.notifier).fetchStats(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('خطا: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(statsProvider.notifier).fetchStats(),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.read(statsProvider.notifier).fetchStats(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('وضعیت سرویس'),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'وضعیت',
                      value: stats.system.isPaused ? 'متوقف' : 'فعال',
                      icon: stats.system.isPaused
                          ? Icons.pause_circle
                          : Icons.check_circle,
                      color: stats.system.isPaused ? Colors.orange : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: 'اتصالات فعال',
                      value: '${stats.system.activeConnections}',
                      icon: Icons.wifi,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'مدت روشن بودن',
                      value: stats.system.uptimeFormatted,
                      icon: Icons.timer,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: 'نسخه',
                      value: stats.system.version,
                      icon: Icons.info,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('کاربران'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _statCard(
                    title: 'کل کاربران',
                    value: '${stats.users.total}',
                    icon: Icons.people,
                    color: Colors.indigo,
                  ),
                  _statCard(
                    title: 'فعال',
                    value: '${stats.users.active}',
                    icon: Icons.check,
                    color: Colors.green,
                  ),
                  _statCard(
                    title: 'متوقف‌شده',
                    value: '${stats.users.paused}',
                    icon: Icons.pause,
                    color: Colors.orange,
                  ),
                  _statCard(
                    title: 'منقضی',
                    value: '${stats.users.expired}',
                    icon: Icons.timer_off,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('مصرف ترافیک'),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'کل مصرف',
                      value: '${stats.traffic.totalGB.toStringAsFixed(2)} GB',
                      icon: Icons.storage,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: 'مصرف امروز',
                      value: '${stats.traffic.dailyGB.toStringAsFixed(2)} GB',
                      icon: Icons.today,
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
