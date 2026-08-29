import '../../../../core/utils/api_enums.dart';

/// بيانات المستخدم الحالي — `GET /api/Users/me`
///
/// ⚠️ لم يتم التحقّق من أسماء الحقول مقابل الـ API (الخادم كان متوقّفاً عند
/// كتابة هذا الملف)، لذلك القراءة هنا **متسامحة**:
/// - كل الحقول اختيارية ما عدا [userId].
/// - [role] و [driverStatus] يُقرأان سواء أرسل الخادم رقماً أو نصاً.
/// إن اختلفت المفاتيح في الـ Swagger فالتعديل يكون في [UserDto.fromJson] فقط.
class UserDto {
  const UserDto({
    required this.userId,
    required this.fullName,
    this.email,
    this.phone,
    this.whatsApp,
    this.role,
    this.factoryId,
    this.factoryName,
    this.driverStatus,
    this.truckPlate,
    this.isActive = true,
  });

  final int userId;
  final String fullName;
  final String? email;
  final String? phone;
  final String? whatsApp;
  final UserRole? role;
  final int? factoryId;
  final String? factoryName;
  final DriverStatus? driverStatus;
  final String? truckPlate;
  final bool isActive;

  bool get isDriver => role == UserRole.driver;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      whatsApp: json['whatsApp'] as String?,
      role: _parseRole(json['role']),
      factoryId: json['factoryId'] as int?,
      factoryName: json['factoryName'] as String?,
      driverStatus: _parseDriverStatus(json['driverStatus']),
      truckPlate: json['truckPlate'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static UserRole? _parseRole(dynamic raw) {
    if (raw is int) return _at(UserRole.values, raw);
    if (raw is String) {
      final asInt = int.tryParse(raw);
      if (asInt != null) return _at(UserRole.values, asInt);
      try {
        return UserRole.fromApiString(raw);
      } on ArgumentError {
        return null;
      }
    }
    return null;
  }

  static DriverStatus? _parseDriverStatus(dynamic raw) {
    if (raw is int) return _at(DriverStatus.values, raw);
    if (raw is String) {
      final asInt = int.tryParse(raw);
      if (asInt != null) return _at(DriverStatus.values, asInt);
      return switch (raw) {
        'Available' => DriverStatus.available,
        'Busy' => DriverStatus.busy,
        'Offline' => DriverStatus.offline,
        _ => null,
      };
    }
    return null;
  }

  /// قراءة آمنة بالفهرس — تتجنّب RangeError لو أضاف الخادم قيمة جديدة.
  static T? _at<T>(List<T> values, int index) =>
      index >= 0 && index < values.length ? values[index] : null;
}
