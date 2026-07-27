import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../keys/presentation/keys_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.vpn_key_outlined),
          title: const Text('کلیدهای API'),
          subtitle: const Text('ساخت و باطل کردن کلید دسترسی'),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KeysScreen()),
          ),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('درباره برنامه'),
          subtitle: Text('پنل مدیریت نهان'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'خروج از حساب',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خروج'),
        content: const Text('از حساب خود خارج می‌شوید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'خروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }
}
