import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/keys_providers.dart';
import '../application/keys_state.dart';
import '../data/api_key_model.dart';

class KeysScreen extends ConsumerStatefulWidget {
  const KeysScreen({super.key});

  @override
  ConsumerState<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends ConsumerState<KeysScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(keysNotifierProvider.notifier).loadKeys());
  }

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    final l = d.toLocal();
    return '${l.year}/${l.month.toString().padLeft(2, '0')}/'
        '${l.day.toString().padLeft(2, '0')}  '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showCreateDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ساخت کلید جدید'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'نام کلید',
            hintText: 'مثلاً: اپ موبایل',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('ساخت'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    final ok = await ref.read(keysNotifierProvider.notifier).createKey(name);
    if (!mounted) return;

    if (ok) {
      final created = ref.read(keysNotifierProvider).newlyCreated;
      if (created?.fullKey != null) {
        await _showFullKeyDialog(created!);
      }
      ref.read(keysNotifierProvider.notifier).clearNewlyCreated();
    } else {
      final err = ref.read(keysNotifierProvider).error ?? 'خطای نامشخص';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ساخت کلید ناموفق بود: $err')),
      );
    }
  }

  Future<void> _showFullKeyDialog(ApiKeyEntry key) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('کلید ساخته شد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'این کلید فقط همین یک بار نمایش داده می‌شود. '
              'همین حالا کپی و در جای امن ذخیره‌اش کن.',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                key.fullKey ?? '',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: key.fullKey ?? ''));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('کلید کپی شد')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('کپی'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستم'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRevoke(ApiKeyEntry key) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('باطل کردن کلید'),
        content: Text(
          'کلید «${key.name}» باطل شود؟ '
          'هر برنامه‌ای که از این کلید استفاده می‌کند دسترسی‌اش قطع می‌شود. '
          'این کار برگشت‌پذیر نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('باطل کن'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final done = await ref.read(keysNotifierProvider.notifier).revokeKey(key.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(done ? 'کلید باطل شد' : 'باطل کردن ناموفق بود')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(keysNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('کلیدهای API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(keysNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.keys.length >= 10 ? null : _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('کلید جدید'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(KeysState state) {
    if (state.status == KeysStatus.loading && state.keys.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == KeysStatus.error && state.keys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                state.error ?? 'خطا در دریافت کلیدها',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'مدیریت کلیدها فقط با master key ممکن است.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(keysNotifierProvider.notifier).refresh(),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.keys.isEmpty) {
      return const Center(child: Text('هنوز کلیدی ساخته نشده'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(keysNotifierProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: state.keys.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == state.keys.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'حداکثر ۱۰ کلید مجاز است (${state.keys.length}/10)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }

          final k = state.keys[i];
          return ListTile(
            leading: const Icon(Icons.vpn_key),
            title: Text(k.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.keyPreview,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Text('ساخت: ${_fmt(k.createdAt)}'),
                Text('آخرین استفاده: ${_fmt(k.lastUsed)}'),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'باطل کردن',
              onPressed: () => _confirmRevoke(k),
            ),
          );
        },
      ),
    );
  }
}
