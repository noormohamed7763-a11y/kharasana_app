import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/order_details_dto.dart';

/// تفاصيل طلب واحد.
///
/// يرمي كائن [Failure] نفسه لا `Exception(failure.messageAr)`: لفّ الرسالة
/// في استثناء نصّي كان يمنع الشاشة من التعرّف على نوع الخطأ، فتعرض نصّاً
/// عامّاً واحداً لكل الأسباب — انقطاع الشبكة وانتهاء الجلسة وطلب محذوف سواء.
/// انظر `driverOrdersProvider` الذي يتبع النمط نفسه.
final orderDetailsProvider =
    FutureProvider.family.autoDispose<OrderDetailsDto, int>((ref, orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderById(orderId);
  return switch (result) {
    Success(data: final data) => data,
    Error(failure: final failure) => throw failure,
  };
});
