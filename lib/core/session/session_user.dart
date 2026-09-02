import '../utils/api_enums.dart';

/// هوية المستخدم الحالي كما حُفظت في التخزين الآمن عند تسجيل الدخول.
///
/// لماذا لا نجلبها من الخادم؟
/// لا يوجد في الواجهة البرمجية الحالية أي مسار يسمح للمستخدم بقراءة ملفه:
///   • `GET /api/Users/me`   → 405 (المسار مُعرَّف لـ PUT فقط)
///   • `GET /api/Users/{id}` → 403 لدور Driver
/// لذلك نعتمد على `SecureStorageService` التي تخزّن الاسم والدور والمعرّف
/// وقت تسجيل الدخول.
///
/// حالة توفّر السائق ليست هنا عمداً: مالكها
/// `DriverStatusController`. وجودها في هذا الكائن كان يفرض إبطال
/// `sessionUserProvider` بعد كل تبديل حالة، فتُعاد قراءة الجلسة كلها
/// وتُهدَم الشرائح المبنيّة داخل `when` الخاص به.
class SessionUser {
  const SessionUser({
    required this.userId,
    required this.fullName,
    required this.role,
  });

  final int? userId;
  final String? fullName;

  /// الدور كما خُزِّن نصياً (مثل `driver` أو `client`).
  final String? role;

  bool get isDriver => role == UserRole.driver.name;

  bool get isClient => role == UserRole.client.name; // ✅ مفيد للتحقق

  /// اسم للعرض حتى لو لم يُخزَّن الاسم لأي سبب.
  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : 'مستخدم';
}