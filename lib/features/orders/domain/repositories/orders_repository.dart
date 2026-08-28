import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/create_order_dto.dart';
import '../../data/models/order_details_dto.dart';
import '../../data/models/order_summary_dto.dart';

abstract class OrdersRepository {
  Future<Result<int>> createOrder(CreateOrderDto dto);

  Future<Result<PagedResult<OrderSummaryDto>>> getOrders({
    required int pageNumber,
    String? search,
  });

  Future<Result<OrderDetailsDto>> getOrderById(int id);

  // ---- إجراءات السائق ----

  /// السائق يبدأ التوصيل: Approved → OnTheWay
  Future<Result<void>> startDelivery(int orderId);

  /// السائق يؤكّد التسليم: OnTheWay → Delivered
  Future<Result<void>> deliverOrder(int orderId);
}
