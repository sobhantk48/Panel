import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ذخیره و بازیابی تنظیمات ظاهری برنامه (تم و زبان).
class SettingsService {
  static const _kThemeMode = 'settings_theme_mode';
  static const _kLocale = 'settings_locale';

  final FlutterSecureStorage _storage;

  SettingsService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// مقادیر ممکن: system | light | dark
  Future<String?> readThemeMode() => _storage.read(key: _kThemeMode);

  Future<void> writeThemeMode(String value) =>
      _storage.write(key: _kThemeMode, value: value);

  /// مقادیر ممکن: system | fa | en
  Future<String?> readLocale() => _storage.read(key: _kLocale);

  Future<void> writeLocale(String value) =>
      _storage.write(key: _kLocale, value: value);
}
