import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/settings/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('ظاهر برنامه'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  title: const Text('پیش‌فرض سیستم'),
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  title: const Text('روشن'),
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  title: const Text('تاریک'),
                  onChanged: (v) =>
                      ref.read(themeModeProvider.notifier).setMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('زبان'),
          Card(
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  groupValue: locale?.languageCode,
                  title: const Text('پیش‌فرض سیستم'),
                  onChanged: (_) =>
                      ref.read(localeProvider.notifier).setLocale(null),
                ),
                RadioListTile<String?>(
                  value: 'fa',
                  groupValue: locale?.languageCode,
                  title: const Text('فارسی'),
                  onChanged: (_) => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('fa')),
                ),
                RadioListTile<String?>(
                  value: 'en',
                  groupValue: locale?.languageCode,
                  title: const Text('English'),
                  onChanged: (_) => ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('خروج از حساب'),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خروج'),
        content: const Text('از حساب خارج می‌شوی؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
