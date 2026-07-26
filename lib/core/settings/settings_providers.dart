import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (_) => SettingsService(),
);

/// ---------------- Theme Mode ----------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _service;

  ThemeModeNotifier(this._service) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _service.readThemeMode();
    state = _fromString(saved);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _service.writeThemeMode(_toString(mode));
  }

  static ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.read(settingsServiceProvider)),
);

/// ---------------- Locale ----------------
/// مقدار null یعنی «پیروی از زبان سیستم».

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsService _service;

  LocaleNotifier(this._service) : super(const Locale('fa')) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _service.readLocale();
    state = _fromString(saved);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await _service.writeLocale(locale?.languageCode ?? 'system');
  }

  static Locale? _fromString(String? value) {
    switch (value) {
      case 'en':
        return const Locale('en');
      case 'fa':
        return const Locale('fa');
      case 'system':
        return null;
      default:
        // پیش‌فرض برنامه فارسی است
        return const Locale('fa');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(ref.read(settingsServiceProvider)),
);
