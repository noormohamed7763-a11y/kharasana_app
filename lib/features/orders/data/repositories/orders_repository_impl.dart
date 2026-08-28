import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/create_order_dto.dart';
import '../models/order_details_dto.dart';
import '../models/order_summary_dto.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);
  final OrdersRemoteDataSource _remote;

  @override
  Future<Result<int>> createOrder(CreateOrderDto dto) async {
    try {
      final orderId = await _remote.createOrder(dto);
      return Success(orderId);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('OrdersRepository', e, st, 'فشل غير متوقع أثناء إنشاء الطلب');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<PagedResult<OrderSummaryDto>>> getOrders({
    required int pageNumber,
    String? search,
  }) async {
    try {
      final result = await _remote.getOrders(
        pageNumber: pageNumber,
        search: search,
      );
      return Success(result);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('OrdersRepository', e, st, 'فشل غير متوقع أثناء جلب الطلبات');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<OrderDetailsDto>> getOrderById(int id) async {
    try {
      final result = await _remote.getOrderById(id);
      return Success(result);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('OrdersRepository', e, st, 'فشل غير متوقع أثناء جلب تفاصيل الطلب #$id');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> startDelivery(int orderId) async {
    try {
      await _remote.startDelivery(orderId);
      return const Success(null);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('OrdersRepository', e, st, 'فشل غير متوقع أثناء بدء التوصيل #$orderId');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> deliverOrder(int orderId) async {
    try {
      await _remote.deliverOrder(orderId);
      return const Success(null);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('OrdersRepository', e, st, 'فشل غير متوقع أثناء تأكيد التسليم #$orderId');
      return const Error(UnknownFailure());
    }
  }
}