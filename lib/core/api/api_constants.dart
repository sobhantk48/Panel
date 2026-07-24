class ApiConstants {
  ApiConstants._();

  // این مقدار در تنظیمات اولیه از کاربر گرفته میشه (پیش‌فرض: sync)
  static const String defaultApiRoute = 'sync';

  // کلیدهای ذخیره‌سازی امن (باید همه‌جا همین‌ها استفاده بشن)
  static const String keyBaseUrl = 'base_url';
  static const String keyApiKey = 'api_key';
  static const String keyApiRoute = 'api_route';

  static String auth(String route) => '/$route/api/auth';
  static String users(String route) => '/$route/api/users';
  static String stats(String route) => '/$route/api/stats';
  static String update(String route) => '/$route/api/update';
}
