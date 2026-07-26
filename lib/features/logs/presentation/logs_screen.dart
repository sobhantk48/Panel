import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logsNotifierProvider.notifier).loadLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconFor(String type) {
    final t = type.toLowerCase();
    if (t.contains('delete')) return Icons.delete_outline;
    if (t.contains('create') || t.contains('add')) return Icons.add_circle_outline;
    if (t.contains('update') || t.contains('edit')) return Icons.edit_outlined;
    if (t.contains('login')) return Icons.login;
    if (t.contains('logout')) return Icons.logout;
    if (t.contains('error') || t.contains('fail')) return Icons.error_outline;
    if (t.contains('renew') || t.contains('reset')) return Icons.autorenew;
    return Icons.info_outline;
  }

  Color _colorFor(String type) {
    final t = type.toLowerCase();
    if (t.contains('delete') || t.contains('error') || t.contains('fail')) {
      return Colors.red;
    }
    if (t.contains('create') || t.contains('add')) return Colors.green;
    if (t.contains('update') || t.contains('edit')) return Colors.orange;
    if (t.contains('login') || t.contains('logout')) return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logsNotifierProvider);
    final notifier = ref.read(logsNotifierProvider.notifier);
    final logs = state.filteredLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لاگ‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'بازخوانی',
            onPressed: state.isLoading ? null : () => notifier.loadLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'جستجو در لاگ‌ها...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: state.availableTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final type = state.availableTypes[i];
                final selected = state.selectedType == type;
                return Center(
                  child: FilterChip(
                    label: Text(type == 'all' ? 'همه' : type),
                    selected: selected,
                    onSelected: (_) => notifier.setType(type),
                  ),
                );
              },
            ),
          ),
          if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.error != null && state.logs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => notifier.loadLogs(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!state.isLoading && logs.isEmpty) {
                  return const Center(
                    child: Text(
                      'لاگی یافت نشد',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => notifier.loadLogs(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final color = _colorFor(log.type);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(_iconFor(log.type), size: 18, color: color),
                        ),
                        title: Text(
                          log.type,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(log.detail, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              log.formattedDate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
