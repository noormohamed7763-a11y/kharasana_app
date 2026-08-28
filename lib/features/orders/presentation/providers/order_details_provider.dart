import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/order_details_dto.dart';

final orderDetailsProvider =
    FutureProvider.family.autoDispose<OrderDetailsDto, int>((ref, orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderById(orderId);
  return switch (result) {
    Success(data: final data) => data,
    Error(failure: final failure) => throw Exception(failure.messageAr),
  };
});
