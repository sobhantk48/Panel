import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('fa'),
  });

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const _kTheme = 'app_theme_mode';
  static const _kLang = 'app_lang_code';

  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final theme = sp.getString(_kTheme) ?? 'system';
    final lang = sp.getString(_kLang) ?? 'fa';
    state = AppSettings(
      themeMode: _parseTheme(theme),
      locale: Locale(lang),
    );
  }

  ThemeMode _parseTheme(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTheme, _themeToString(mode));
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLang, locale.languageCode);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (_) => SettingsNotifier(),
);
