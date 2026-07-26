import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('خروج از حساب'),
        content: const Text('از حساب خود خارج می‌شوید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorColor = Theme.of(context).colorScheme.error;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('دربارهٔ برنامه'),
          subtitle: Text('پنل مدیریت نهان'),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: errorColor),
          title: Text('خروج از حساب', style: TextStyle(color: errorColor)),
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }
}
