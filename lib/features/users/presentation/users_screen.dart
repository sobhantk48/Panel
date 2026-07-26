import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../application/users_state.dart';
import '../data/user_model.dart';
import 'user_form_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(usersNotifierProvider.notifier).loadUsers(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  Color _statusColor(String status) => switch (status) {
        'active' => Colors.green,
        'paused' => Colors.orange,
        'expired' => Colors.red,
        'auto-disabled' => Colors.redAccent,
        _ => Colors.grey,
      };

  String _statusLabel(String status) => switch (status) {
        'active' => 'فعال',
        'paused' => 'متوقف',
        'expired' => 'منقضی',
        'auto-disabled' => 'غیرفعال خودکار',
        _ => status,
      };

  /// قالب‌بندی حجم به سبک پنل نهان (3.00 GB / 1.02 GB)
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0.00 GB';
    const kb = 1024.0;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(2)} MB';
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }

  /// جداکننده هزارگان برای تعداد درخواست‌ها (6,098)
  String _formatCount(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return (n < 0 ? '-' : '') + buf.toString();
  }

  /// اولین کاراکتر معنادار نام برای آواتار (کاما و فاصله را رد می‌کند)
  String _initial(String name) {
    for (final ch in name.trim().split('')) {
      if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(ch)) {
        return ch.toUpperCase();
      }
    }
    return '?';
  }

  /// متن لاتین/عددی را در جهت LTR می‌گذارد تا bidi آن را به هم نریزد.
  Widget _ltr(String text, {TextStyle? style}) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text(text, style: style),
      );

  // ---------- usage block ----------

  Widget _usageInfo(BuildContext context, UserUsage usage) {
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 11.5);

    final hasTotalLimit = usage.limit > 0;
    final ratio =
        hasTotalLimit ? (usage.total / usage.limit).clamp(0.0, 1.0) : 0.0;
    final percentText = '${(ratio * 100).toStringAsFixed(1)}%';

    final barColor = ratio >= 0.9
        ? Colors.red
        : ratio >= 0.7
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        // خط ترافیک کل
        Row(
          children: [
            Text('کل:', style: hintStyle),
            const SizedBox(width: 4),
            _ltr(
              hasTotalLimit
                  ? '${_formatBytes(usage.total)} / ${_formatBytes(usage.limit)}'
                  : _formatBytes(usage.total),
              style: hintStyle?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            if (hasTotalLimit)
              _ltr(
                percentText,
                style: hintStyle?.copyWith(color: barColor),
              )
            else
              Text('نامحدود', style: hintStyle?.copyWith(color: Colors.blue)),
          ],
        ),
        if (hasTotalLimit) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
        const SizedBox(height: 4),
        // خط مصرف روزانه (واحد: درخواست، مطابق پنل نهان)
        Row(
          children: [
            Text('روزانه:', style: hintStyle),
            const SizedBox(width: 4),
            _ltr(_formatCount(usage.daily), style: hintStyle),
            Text(' درخواست', style: hintStyle),
            const SizedBox(width: 6),
            Text('•', style: hintStyle),
            const SizedBox(width: 6),
            Text('سقف:', style: hintStyle),
            const SizedBox(width: 4),
            if (usage.dailyLimit > 0)
              _ltr(_formatCount(usage.dailyLimit), style: hintStyle)
            else
              Text('نامحدود', style: hintStyle?.copyWith(color: Colors.blue)),
          ],
        ),
      ],
    );
  }

  // ---------- actions ----------

  void _confirmDelete(NahanUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف کاربر'),
        content: Text('آیا از حذف "${user.name}" مطمئنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ref
                  .read(usersNotifierProvider.notifier)
                  .deleteUser(user.id);
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

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'جستجو بر اساس نام یا شناسه...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(usersNotifierProvider.notifier).loadUsers();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (v) {
              setState(() {});
              ref
                  .read(usersNotifierProvider.notifier)
                  .loadUsers(query: v.isEmpty ? null : v);
            },
          ),
        ),
        Expanded(
          child: switch (state.status) {
            UsersStatus.loading || UsersStatus.initial =>
              const Center(child: CircularProgressIndicator()),
            UsersStatus.error => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.error ?? 'خطا در دریافت اطلاعات',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            UsersStatus.loaded => state.users.isEmpty
                ? const Center(child: Text('کاربری یافت نشد'))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(usersNotifierProvider.notifier).loadUsers(
                              query: _searchController.text.isEmpty
                                  ? null
                                  : _searchController.text,
                            ),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.users.length,
                      itemBuilder: (_, i) {
                        final u = state.users[i];
                        final usage = u.usage;
                        final color = _statusColor(u.status);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      color.withValues(alpha: 0.15),
                                  child: Text(
                                    _initial(u.name),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              u.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                  alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _statusLabel(u.status),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (usage != null)
                                        _usageInfo(context, usage),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserFormScreen(user: u),
                                        ),
                                      );
                                    } else if (v == 'delete') {
                                      _confirmDelete(u);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('ویرایش'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'حذف',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          },
        ),
      ],
    );
  }
}
