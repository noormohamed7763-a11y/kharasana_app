import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/create_order_dto.dart';
import '../models/order_details_dto.dart';
import '../models/order_summary_dto.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._dio);
  final Dio _dio;

  Future<int> createOrder(CreateOrderDto dto) async {
    final response = await _dio.post(
      ApiEndpoints.orders,
      data: dto.toJson(),
    );
    // نفترض أن الاستجابة ترجع { "data": { "orderId": 123 } }
    final data = response.data as Map<String, dynamic>;
    return data['data']['orderId'] as int;
  }

  Future<PagedResult<OrderSummaryDto>> getOrders({
    required int pageNumber,
    int pageSize = 20,
    String? search,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.orders,
      queryParameters: {
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        if (search != null && search.isNotEmpty) 'Search': search,
      },
    );
    final apiResponse = ApiResponse<PagedResult<OrderSummaryDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PagedResult<OrderSummaryDto>.fromJson(
        json as Map<String, dynamic>,
        (item) => OrderSummaryDto.fromJson(item),
      ),
    );
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.orders),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.orders),
          data: {'message': apiResponse.message},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    if (apiResponse.data == null) {
      throw Exception('تعذر قراءة بيانات الطلبات من الخادم.');
    }
    return apiResponse.data!;
  }

  Future<OrderDetailsDto> getOrderById(int id) async {
    final response = await _dio.get(ApiEndpoints.orderById(id));
    final apiResponse = ApiResponse<OrderDetailsDto>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => OrderDetailsDto.fromJson(json as Map<String, dynamic>),
    );
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.orderById(id)),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.orderById(id)),
          data: {'message': apiResponse.message},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    if (apiResponse.data == null) {
      throw Exception('تعذر قراءة بيانات تفاصيل الطلب من الخادم.');
    }
    return apiResponse.data!;
  }

  /// ⚠️ افتراض: كلا المسارين PUT بدون body — غير مُتحقَّق منه مقابل الخادم بعد.
  Future<void> startDelivery(int orderId) async {
    await _dio.put(ApiEndpoints.startDelivery(orderId));
  }

  Future<void> deliverOrder(int orderId) async {
    await _dio.put(ApiEndpoints.deliverOrder(orderId));
  }
}