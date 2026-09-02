import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/providers/core_providers.dart';
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

// حالة توفّر السائق انتقلت إلى `driver_status_controller.dart`.
// كانت هنا `FutureProvider.autoDispose.family<void, DriverStatus>` وهو نمط
// خاطئ لإجراء: يخزّن نتيجة كل حالة على حدة فيتخطّى الطلب عند إعادة اختيارها،
// ويُبطل `sessionUserProvider` الذي كانت الشريحة مبنيّة داخل `when` الخاص به
// فتُهدَم من الشجرة وتظهر الضغطة بلا أثر.
