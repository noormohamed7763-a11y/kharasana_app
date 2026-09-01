import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/result.dart';
import '../../../orders/data/models/order_summary_dto.dart';

/// طلبات السائق الحالي.
///
/// ⚠️ نطاق العزل غير مؤكَّد: رمز الدخول (JWT) للسائق يحمل `FactoryId` إلى
/// جانب `role: Driver`، لذا من المرجّح أن `GET /api/Orders` يُفلتر بالمصنع
/// وليس بالسائق. مع طلب واحد في البيانات الحالية لا يمكن التمييز بين
/// الحالتين. إن ظهرت للسائق طلبات غير مُسنَدة إليه فأضف الفلترة هنا
/// بمقارنة `driverId` بمعرّف المستخدم من [sessionUserProvider] — وهو ما
/// يستلزم إضافة `driverId` إلى `OrderSummaryDto` في الخادم (غير موجود حالياً
/// في استجابة القائمة، بل في تفاصيل الطلب فقط).
///
/// يرمي كائن [Failure] نفسه (لا `Exception` نصية) حتى تعرض الشاشة
/// `messageAr` مباشرةً بدل نص «Exception: …».
final driverOrdersProvider =
    FutureProvider.autoDispose<List<OrderSummaryDto>>((ref) async {
  final result =
      await ref.watch(ordersRepositoryProvider).getOrders(pageNumber: 1);
  return switch (result) {
    Success(data: final page) => page.items,
    Error(failure: final failure) => throw failure,
  };
});

/// نص الخطأ المناسب للعرض من كائن خطأ قادم من أي provider.
String failureMessage(Object error) =>
    error is Failure ? error.messageAr : 'حدث خطأ غير متوقع.';

/// يحدّث حالة توفّر السائق في الخادم ثم يحفظها محلياً فوراً.
///
/// لا نعتمد على قراءتها لاحقاً عبر GET /api/Users/{id} لأن هذا المسار
/// يرجع 403 لدور Driver في الخادم الحالي — الحفظ المحلي بعد نجاح التحديث
/// هو مصدر الحقيقة الوحيد المتاح حالياً.
final driverStatusUpdateProvider =
    FutureProvider.autoDispose.family<void, DriverStatus>((ref, status) async {
  final storage = ref.watch(secureStorageProvider);
  final userId = await storage.readUserId();
  if (userId == null) throw const UnauthorizedFailure();

  final result = await ref.watch(profileRepositoryProvider).updateDriverStatus(userId, status);
  switch (result) {
    case Success():
      await storage.saveDriverStatus(status.index);
      ref.invalidate(sessionUserProvider);
    case Error(failure: final failure):
      throw failure;
  }
});