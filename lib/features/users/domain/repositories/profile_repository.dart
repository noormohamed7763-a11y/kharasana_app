import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/user_dto.dart';

abstract class ProfileRepository {
  /// بيانات المستخدم المسجَّل دخوله حالياً.
  Future<Result<UserDto>> getMyProfile();

  /// تبديل حالة توفّر السائق (متاح / مشغول / غير متصل).
  Future<Result<void>> updateDriverStatus(int userId, DriverStatus status);

  // ============================================================
  // ✅ إضافة الدوال المفقودة
  // ============================================================

  /// تحديث الملف الشخصي (الاسم، الهاتف، واتساب).
  Future<Result<void>> updateMyProfile({
    String? fullName,
    String? phone,
    String? whatsApp,
  });

  /// تسجيل الخروج ومسح الجلسة.
  Future<void> logout();
}