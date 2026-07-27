import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// تنظیمات ظاهری و زبان برنامه
class AppSettings {
  final ThemeMode themeMode;
  final String languageCode;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'fa',
  });

  Locale get locale => Locale(languageCode);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  static const _kThemeKey = 'app_theme_mode';
  static const _kLangKey = 'app_language_code';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// خواندن تنظیمات ذخیره‌شده در اجرای برنامه
  Future<void> load() async {
    try {
      final theme = await _storage.read(key: _kThemeKey);
      final lang = await _storage.read(key: _kLangKey);

      state = state.copyWith(
        themeMode: _parseTheme(theme),
        languageCode: (lang == 'en' || lang == 'fa') ? lang : 'fa',
      );
    } catch (_) {
      // اگر خواندن حافظه امن خطا داد، مقادیر پیش‌فرض می‌ماند
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      await _storage.write(key: _kThemeKey, value: mode.name);
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    try {
      await _storage.write(key: _kLangKey, value: code);
    } catch (_) {}
  }

  ThemeMode _parseTheme(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier()..load(),
);
