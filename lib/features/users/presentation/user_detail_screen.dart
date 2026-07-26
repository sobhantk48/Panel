import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/providers/providers.dart';
import '../data/user_model.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends ConsumerWidget {
  final NahanUser user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نسخه به‌روز کاربر را از لیست می‌خوانیم تا بعد از toggle/reset تازه بماند.
    final users = ref.watch(usersNotifierProvider).users;
    final u = users.firstWhere(
      (e) => e.id == user.id,
      orElse: () => user,
    );

    final isActive = u.status == 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(u.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'ویرایش',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserFormScreen(user: u)),
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'عملیات بیشتر',
            onSelected: (value) => _onAction(context, ref, u, value),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(isActive ? Icons.pause_circle : Icons.play_circle),
                    const SizedBox(width: 12),
                    Text(isActive ? 'غیرفعال کردن' : 'فعال کردن'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 12),
                    Text('صفر کردن مصرف'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('حذف کاربر', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(user: u),
          const SizedBox(height: 16),
          _UsageCard(
            title: 'مصرف کل',
            used: u.usage?.total ?? 0,
            limit: u.usage?.limit ?? u.limitTotalReq ?? 0,
            icon: Icons.data_usage,
          ),
          const SizedBox(height: 12),
          _UsageCard(
            title: 'مصرف امروز',
            used: u.usage?.daily ?? 0,
            limit: u.usage?.dailyLimit ?? u.limitDailyReq ?? 0,
            icon: Icons.today,
          ),
          const SizedBox(height: 16),
          if (u.subscriptionUrl != null && u.subscriptionUrl!.isNotEmpty)
            _SubscriptionCard(url: u.subscriptionUrl!),
          const SizedBox(height: 16),
          _InfoCard(user: u),
        ],
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    NahanUser u,
    String action,
  ) async {
    final notifier = ref.read(usersNotifierProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    switch (action) {
      case 'toggle':
        final ok = await notifier.toggleUser(u.id);
        messenger.showSnackBar(SnackBar(
          content: Text(ok ? 'وضعیت کاربر تغییر کرد' : 'تغییر وضعیت ناموفق بود'),
        ));
        break;

      case 'reset':
        final confirm = await _confirm(
          context,
          title: 'صفر کردن مصرف',
          message: 'مصرف «${u.name}» صفر شود؟ این کار قابل بازگشت نیست.',
          okText: 'صفر کن',
        );
        if (confirm != true) return;
        final ok = await notifier.resetUsage(u.id);
        messenger.showSnackBar(SnackBar(
          content: Text(ok ? 'مصرف صفر شد' : 'صفر کردن مصرف ناموفق بود'),
        ));
        break;

      case 'delete':
        final confirm = await _confirm(
          context,
          title: 'حذف کاربر',
          message: 'کاربر «${u.name}» حذف شود؟ این کار قابل بازگشت نیست.',
          okText: 'حذف',
          danger: true,
        );
        if (confirm != true) return;
        final ok = await notifier.deleteUser(u.id);
        if (!context.mounted) return;
        if (ok) {
          Navigator.pop(context);
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('حذف کاربر ناموفق بود')),
          );
        }
        break;
    }
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String okText,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              okText,
              style: TextStyle(color: danger ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- کارت وضعیت ----------------

class _StatusCard extends StatelessWidget {
  final NahanUser user;
  const _StatusCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';
    final color = isActive ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                isActive ? Icons.check_circle : Icons.pause_circle,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive ? 'فعال' : 'غیرفعال',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              tooltip: 'کپی شناسه',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: user.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('شناسه کپی شد')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- کارت مصرف ----------------

class _UsageCard extends StatelessWidget {
  final String title;
  final int used;
  final int limit;
  final IconData icon;

  const _UsageCard({
    required this.title,
    required this.used,
    required this.limit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final usedGb = used / 6000;
    final limitGb = limit / 6000;
    final hasLimit = limit > 0;
    final ratio = hasLimit ? (used / limit).clamp(0.0, 1.0) : 0.0;

    Color barColor = Colors.green;
    if (ratio > 0.9) {
      barColor = Colors.red;
    } else if (ratio > 0.7) {
      barColor = Colors.orange;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  hasLimit
                      ? '${usedGb.toStringAsFixed(2)} از ${limitGb.toStringAsFixed(2)} GB'
                      : '${usedGb.toStringAsFixed(2)} GB (نامحدود)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: hasLimit ? ratio.toDouble() : 0,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            if (hasLimit) ...[
              const SizedBox(height: 6),
              Text(
                '${(ratio * 100).toStringAsFixed(1)}٪ مصرف شده',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ---------------- کارت اشتراک و QR ----------------

class _SubscriptionCard extends StatelessWidget {
  final String url;
  const _SubscriptionCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_2, size: 20),
                const SizedBox(width: 8),
                Text(
                  'لینک اشتراک',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => _showFullQr(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (_, __) => const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(child: Text('QR ساخته نشد')),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'برای بزرگ‌نمایی روی تصویر بزن',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('کپی لینک'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لینک اشتراک کپی شد')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 280,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('بستن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- کارت اطلاعات ----------------

class _InfoCard extends StatelessWidget {
  final NahanUser user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      ['شناسه', user.id],
      ['تاریخ ساخت', _formatDate(user.createdAt)],
      ['تاریخ انقضا', _formatDate(user.expiryMs)],
      ['حجم کل', _gb(user.limitTotalReq)],
      ['حجم روزانه', _gb(user.limitDailyReq)],
      ['حداکثر کانفیگ', user.maxConfigs?.toString() ?? '—'],
      ['محدودیت اتصال', user.connLimit?.toString() ?? '—'],
      ['حالت کاربر', user.userMode ?? '—'],
      ['پورت‌ها', user.userPorts ?? '—'],
      ['نودها', user.userNodes ?? '—'],
      ['Proxy IP', user.proxyIp ?? '—'],
      ['Clean IP', user.cleanIp ?? '—'],
      ['NAT64', user.nat64 ?? '—'],
      ['پنل کاربر', user.userPanelUrl ?? '—'],
      ['یادداشت', (user.notes?.isNotEmpty ?? false) ? user.notes! : '—'],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'اطلاعات کاربر',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final row in rows) ...[
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      row[0],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row[1],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _gb(int? req) {
    if (req == null || req == 0) return 'نامحدود';
    return '${(req / 6000).toStringAsFixed(2)} GB';
  }

  static String _formatDate(int? ms) {
    if (ms == null || ms == 0) return 'نامحدود';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('yyyy/MM/dd  HH:mm').format(dt);
  }
}
