// ⚠️ ملف مهجور (dead code): لا يستورده أي ملف في المشروع.
// الواجهة الفعلية المستخدمة هي:
//   lib/features/orders/domain/repositories/orders_repository.dart
// وهي أحدث من هذه (تحتوي getOrderById و startDelivery و deliverOrder).
// أُصلحت المسارات هنا فقط ليعود `flutter analyze` نظيفاً — والأفضل حذف
// المجلد lib/features/orders/data/domain/ بالكامل.
import '../../../../../core/network/api_response.dart';
import '../../../../../core/utils/result.dart';
import '../../models/create_order_dto.dart';
import '../../models/order_summary_dto.dart';

abstract class OrdersRepository {
  Future<Result<int>> createOrder(CreateOrderDto dto);
  
  Future<Result<PagedResult<OrderSummaryDto>>> getOrders({
    required int pageNumber,
    String? search,
  });
}