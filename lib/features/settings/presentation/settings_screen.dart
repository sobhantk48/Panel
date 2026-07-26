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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('ظاهر برنامه'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeMode,
                secondary: const Icon(Icons.brightness_auto_outlined),
                title: const Text('پیش‌فرض سیستم'),
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setMode(v!),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeMode,
                secondary: const Icon(Icons.light_mode_outlined),
                title: const Text('روشن'),
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setMode(v!),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeMode,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('تاریک'),
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setMode(v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('زبان'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              RadioListTile<String?>(
                value: null,
                groupValue: locale?.languageCode,
                secondary: const Icon(Icons.translate_outlined),
                title: const Text('پیش‌فرض سیستم'),
                onChanged: (_) =>
                    ref.read(localeProvider.notifier).setLocale(null),
              ),
              RadioListTile<String?>(
                value: 'fa',
                groupValue: locale?.languageCode,
                secondary: const Text('🇮🇷', style: TextStyle(fontSize: 22)),
                title: const Text('فارسی'),
                onChanged: (_) => ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('fa')),
              ),
              RadioListTile<String?>(
                value: 'en',
                groupValue: locale?.languageCode,
                secondary: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                title: const Text('English'),
                onChanged: (_) => ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('en')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('حساب کاربری'),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'خروج از حساب',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _logout(context, ref),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Panel v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ),
      ],
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
