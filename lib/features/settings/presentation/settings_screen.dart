import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../keys/presentation/keys_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return ListView(
      children: [
        _sectionTitle(context, 'ظاهر برنامه'),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: const Text('تم برنامه'),
          subtitle: Text(_themeLabel(settings.themeMode)),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => _pickTheme(context, ref, settings.themeMode),
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: const Text('زبان برنامه'),
          subtitle: Text(_langLabel(settings.languageCode)),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => _pickLanguage(context, ref, settings.languageCode),
        ),
        const Divider(),
        _sectionTitle(context, 'دسترسی'),
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

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'روشن';
      case ThemeMode.dark:
        return 'تاریک';
      case ThemeMode.system:
        return 'پیروی از سیستم';
    }
  }

  String _langLabel(String code) => code == 'en' ? 'English' : 'فارسی';

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('انتخاب تم'),
            ),
            _optionTile(
              ctx,
              icon: Icons.settings_suggest_outlined,
              title: 'پیروی از سیستم',
              selected: current == ThemeMode.system,
              value: ThemeMode.system,
            ),
            _optionTile(
              ctx,
              icon: Icons.light_mode_outlined,
              title: 'روشن',
              selected: current == ThemeMode.light,
              value: ThemeMode.light,
            ),
            _optionTile(
              ctx,
              icon: Icons.dark_mode_outlined,
              title: 'تاریک',
              selected: current == ThemeMode.dark,
              value: ThemeMode.dark,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('انتخاب زبان'),
            ),
            _optionTile(
              ctx,
              icon: Icons.translate,
              title: 'فارسی',
              selected: current == 'fa',
              value: 'fa',
            ),
            _optionTile(
              ctx,
              icon: Icons.translate,
              title: 'English',
              selected: current == 'en',
              value: 'en',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setLanguage(selected);
    }
  }

  Widget _optionTile<T>(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool selected,
    required T value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => Navigator.pop<T>(context, value),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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
            child: const Text('خروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }
}
