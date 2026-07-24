class ApiConstants {
  ApiConstants._();

  // این مقدار در تنظیمات اولیه از کاربر گرفته میشه (پیش‌فرض: sync)
  static const String defaultApiRoute = 'sync';

  static String auth(String route) => '/$route/api/auth';
  static String users(String route) => '/$route/api/users';
  static String stats(String route) => '/$route/api/stats';
  static String update(String route) => '/$route/api/update';
}
