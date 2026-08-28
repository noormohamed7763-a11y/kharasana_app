class AppConstants {
  AppConstants._();

  static const String appName = 'خرسانة';

  // ✅ الرابط الصحيح (من Swagger)
  static const String baseUrlDev = 'http://localhost:5000';

  static const int defaultPageSize = 20;
  static const String currencySymbol = 'ر.ي';
  static const String yemenPhonePrefix = '+967';
}

class StorageKeys {
  StorageKeys._();
  static const String jwtToken = 'kharasana_jwt_token';
  static const String userRole = 'kharasana_user_role';
  static const String userId = 'kharasana_user_id';
  static const String userFullName = 'kharasana_user_full_name';
}