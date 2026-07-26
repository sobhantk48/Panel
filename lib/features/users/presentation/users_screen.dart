import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../application/users_state.dart';
import '../data/user_model.dart';
import 'user_form_screen.dart';
import 'user_detail_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersNotifierProvider.notifier).loadUsers());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(usersNotifierProvider.notifier).loadUsers(query: v.isEmpty ? null : v);
    });
  }

  void _copySubscription(NahanUser user) {
    final url = user.subscriptionUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لینک اشتراک موجود نیست')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لینک اشتراک کپی شد'), duration: Duration(seconds: 1)),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'active' => Colors.green,
        'paused' => Colors.orange,
        'expired' => Colors.red,
        _ => Colors.grey,
      };

  String _statusLabel(String status) => switch (status) {
        'active' => 'فعال',
        'paused' => 'متوقف',
        'expired' => 'منقضی',
        'auto-disabled' => 'غیرفعال خودکار',
        _ => status,
      };

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _confirmDelete(NahanUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف کاربر'),
        content: Text('آیا از حذف "${user.name}" مطمئنید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ref.read(usersNotifierProvider.notifier).deleteUser(user.id);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خطا در حذف کاربر')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('کاربران'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو (نام، ID، یادداشت)...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _debounce?.cancel();
                          _searchController.clear();
                          ref.read(usersNotifierProvider.notifier).loadUsers();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserFormScreen()),
        ),
        child: const Icon(Icons.person_add),
      ),
      body: switch (state.status) {
        UsersStatus.loading || UsersStatus.initial =>
          const Center(child: CircularProgressIndicator()),
        UsersStatus.error =>
          Center(child: Text(state.error ?? 'خطا', style: const TextStyle(color: Colors.red))),
        UsersStatus.loaded => state.users.isEmpty
            ? const Center(child: Text('کاربری یافت نشد'))
            : RefreshIndicator(
                onRefresh: () => ref.read(usersNotifierProvider.notifier).loadUsers(
                      query: _searchController.text.isEmpty ? null : _searchController.text,
                    ),
                child: ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (_, i) {
                    final u = state.users[i];
                    final usage = u.usage;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserDetailScreen(user: u)),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(u.status).withValues(alpha: 0.15),
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                            style: TextStyle(color: _statusColor(u.status), fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                u.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(u.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _statusLabel(u.status),
                                style: TextStyle(fontSize: 11, color: _statusColor(u.status)),
                              ),
                            ),
                          ],
                        ),
                        subtitle: usage != null
                            ? Text(
                                '${_formatBytes(usage.total)} / ${_formatBytes(usage.limit)}  •  روزانه: ${usage.daily}/${usage.dailyLimit}',
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => UserFormScreen(user: u)),
                              );
                            } else if (v == 'delete') {
                              _confirmDelete(u);
                            } else if (v == 'copy') {
                              _copySubscription(u);
                            } else if (v == 'detail') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => UserDetailScreen(user: u)),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'detail', child: Text('جزئیات')),
                            PopupMenuItem(value: 'copy', child: Text('کپی لینک اشتراک')),
                            PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                            PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      },
    );
  }
}
