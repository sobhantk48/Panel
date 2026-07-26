import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/settings_providers.dart';
import '../../auth/application/auth_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fa = Localizations.localeOf(context).languageCode == 'fa';
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _SectionTitle(fa ? 'ظاهر' : 'Appearance'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(fa ? 'سیستم' : 'System'),
                tooltip: fa ? 'پیروی از تم سیستم' : 'Follow system theme',
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode),
                label: Text(fa ? 'روشن' : 'Light'),
                tooltip: fa ? 'تم روشن' : 'Light theme',
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode),
                label: Text(fa ? 'تاریک' : 'Dark'),
                tooltip: fa ? 'تم تاریک' : 'Dark theme',
              ),
            ],
            selected: {themeMode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              ref.read(themeModeProvider.notifier).setMode(selection.first);
            },
          ),
        ),
        const Divider(),
        _SectionTitle(fa ? 'زبان' : 'Language'),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(fa ? 'زبان برنامه' : 'App language'),
          subtitle: Text(_localeLabel(locale, fa)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickLanguage(context, ref, fa, locale),
        ),
        const Divider(),
        _SectionTitle(fa ? 'درباره' : 'About'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(fa ? 'درباره برنامه' : 'About the app'),
          subtitle: Text(fa ? 'پنل مدیریت نهان' : 'Nahan management panel'),
        ),
        ListTile(
          leading: const Icon(Icons.tag),
          title: Text(fa ? 'نسخه' : 'Version'),
          subtitle: const Text('1.0.0'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(
            fa ? 'خروج از حساب' : 'Sign out',
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () => _confirmLogout(context, ref, fa),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static String _localeLabel(Locale? locale, bool fa) {
    if (locale == null) {
      return fa ? 'پیروی از سیستم' : 'Follow system';
    }
    return locale.languageCode == 'en' ? 'English' : 'فارسی';
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    bool fa,
    Locale? current,
  ) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(fa ? 'انتخاب زبان' : 'Select language'),
        children: [
          _LangOption(
            label: 'فارسی',
            value: 'fa',
            selected: current?.languageCode == 'fa',
          ),
          _LangOption(
            label: 'English',
            value: 'en',
            selected: current?.languageCode == 'en',
          ),
          _LangOption(
            label: fa ? 'پیروی از سیستم' : 'Follow system',
            value: 'system',
            selected: current == null,
          ),
        ],
      ),
    );

    if (selected == null) return;

    final notifier = ref.read(localeProvider.notifier);
    if (selected == 'system') {
      await notifier.setLocale(null);
    } else {
      await notifier.setLocale(Locale(selected));
    }
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    bool fa,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(fa ? 'خروج' : 'Sign out'),
        content: Text(
          fa ? 'از حساب خود خارج می‌شوید؟' : 'Do you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(fa ? 'انصراف' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              fa ? 'خروج' : 'Sign out',
              style: const TextStyle(color: Colors.red),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;

  const _LangOption({
    required this.label,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => Navigator.pop(context, value),
    );
  }
}
