import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/user_model.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final NahanUser user;
  const UserDetailScreen({super.key, required this.user});

  Color _statusColor(String s) => switch (s) {
        'active' => Colors.green,
        'paused' => Colors.orange,
        'expired' => Colors.red,
        _ => Colors.grey,
      };

  String _statusLabel(String s) => switch (s) {
        'active' => 'فعال',
        'paused' => 'متوقف',
        'expired' => 'منقضی',
        'auto-disabled' => 'غیرفعال خودکار',
        _ => s,
      };

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDate(int? ms) {
    if (ms == null || ms == 0) return '—';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label کپی شد'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usage = user.usage;
    final totalRatio = (usage != null && usage.limit > 0)
        ? (usage.total / usage.limit).clamp(0.0, 1.0)
        : 0.0;
    final dailyRatio = (usage != null && usage.dailyLimit > 0)
        ? (usage.daily / usage.dailyLimit).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'ویرایش',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // سربرگ وضعیت
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _statusColor(user.status).withValues(alpha: 0.15),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 28,
                      color: _statusColor(user.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(user.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(user.status),
                    style: TextStyle(color: _statusColor(user.status), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // گِیج‌های مصرف
          if (usage != null) ...[
            Text('مصرف', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _GaugeCard(
                    ratio: totalRatio,
                    title: 'حجم کل',
                    subtitle: '${_formatBytes(usage.total)} / ${_formatBytes(usage.limit)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GaugeCard(
                    ratio: dailyRatio,
                    title: 'روزانه',
                    subtitle: '${usage.daily} / ${usage.dailyLimit}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // لینک اشتراک
          if (user.subscriptionUrl != null && user.subscriptionUrl!.isNotEmpty) ...[
            Text('لینک اشتراک', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: Text(
                  user.subscriptionUrl!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copy(context, user.subscriptionUrl!, 'لینک اشتراک'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // مشخصات
          Text('مشخصات', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _row('شناسه (ID)', user.id, copyable: true, context: context),
                _divider(),
                _row('انقضا', _formatDate(user.expiryMs), context: context),
                _divider(),
                _row('ساخته‌شده', _formatDate(user.createdAt), context: context),
                if (user.maxConfigs != null) ...[
                  _divider(),
                  _row('حداکثر کانفیگ', '${user.maxConfigs}', context: context),
                ],
                if (user.connLimit != null) ...[
                  _divider(),
                  _row('محدودیت اتصال', '${user.connLimit}', context: context),
                ],
                if (user.trafficLimitGb != null) ...[
                  _divider(),
                  _row('حجم کل', '${user.trafficLimitGb!.toStringAsFixed(2)} GB', context: context),
                ],
                if (user.dailyLimitGb != null) ...[
                  _divider(),
                  _row('حجم روزانه', '${user.dailyLimitGb!.toStringAsFixed(2)} GB', context: context),
                ],
                if (user.userMode != null) ...[
                  _divider(),
                  _row('حالت', user.userMode!, context: context),
                ],
                if (user.userPorts != null && user.userPorts!.isNotEmpty) ...[
                  _divider(),
                  _row('پورت‌ها', user.userPorts!, context: context),
                ],
                if (user.proxyIp != null && user.proxyIp!.isNotEmpty) ...[
                  _divider(),
                  _row('Proxy IP', user.proxyIp!, copyable: true, context: context),
                ],
                if (user.cleanIp != null && user.cleanIp!.isNotEmpty) ...[
                  _divider(),
                  _row('Clean IP', user.cleanIp!, copyable: true, context: context),
                ],
                if (user.notes != null && user.notes!.isNotEmpty) ...[
                  _divider(),
                  _row('یادداشت', user.notes!, context: context),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _row(String label, String value,
      {bool copyable = false, required BuildContext context}) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      trailing: copyable
          ? IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copy(context, value, label),
            )
          : null,
    );
  }
}

// گِیج حلقه‌ای مصرف با CustomPaint (بدون پکیج اضافه)
class _GaugeCard extends StatelessWidget {
  final double ratio;
  final String title;
  final String subtitle;
  const _GaugeCard({required this.ratio, required this.title, required this.subtitle});

  Color get _color {
    if (ratio >= 0.9) return Colors.red;
    if (ratio >= 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _GaugePainter(ratio: ratio, color: _color),
                child: Center(
                  child: Text(
                    '${(ratio * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _color, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double ratio;
  final Color color;
  _GaugePainter({required this.ratio, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const stroke = 8.0;

    final bg = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.ratio != ratio || old.color != color;
}
