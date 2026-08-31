import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../data/models/order_summary_dto.dart';

sealed class OrdersListState {
  const OrdersListState();
}

class OrdersListInitial extends OrdersListState {
  const OrdersListInitial();
}

class OrdersListLoading extends OrdersListState {
  const OrdersListLoading();
}

class OrdersListLoaded extends OrdersListState {
  final List<OrderSummaryDto> items;
  final int pageNumber;
  final int totalPages;
  final bool isLoadingMore;

  const OrdersListLoaded({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  bool get hasMore => pageNumber < totalPages;

  OrdersListLoaded copyWith({
    List<OrderSummaryDto>? items,
    int? pageNumber,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return OrdersListLoaded(
      items: items ?? this.items,
      pageNumber: pageNumber ?? this.pageNumber,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class OrdersListError extends OrdersListState {
  final String message;
  const OrdersListError(this.message);
}

class OrdersListController extends StateNotifier<OrdersListState> {
  OrdersListController(this._repository) : super(const OrdersListInitial()) {
    loadFirstPage();
  }

  final OrdersRepository _repository;

  Future<void> loadFirstPage() async {
    state = const OrdersListLoading();
    try {
      final result = await _repository.getOrders(pageNumber: 1).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('انتهت مهلة الاتصال بالخادم'),
      );
      switch (result) {
      case Success(data: final paged):
        state = OrdersListLoaded(
          items: paged.items,
          pageNumber: paged.pageNumber,
          totalPages: paged.totalPages,
        );
      case Error(failure: final failure):
        state = OrdersListError(failure.messageAr);
    }
    } catch (e) {
      state = const OrdersListError('حدث خطأ أثناء تحميل الطلبات');
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! OrdersListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    state = current.copyWith(isLoadingMore: true);
    final result = await _repository.getOrders(pageNumber: current.pageNumber + 1);
    switch (result) {
      case Success(data: final paged):
        state = current.copyWith(
          items: [...current.items, ...paged.items],
          pageNumber: paged.pageNumber,
          totalPages: paged.totalPages,
          isLoadingMore: false,
        );
      case Error():
        state = current.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => loadFirstPage();
}

final ordersListControllerProvider = 
    StateNotifierProvider.autoDispose<OrdersListController, OrdersListState>((ref) {
  return OrdersListController(ref.watch(ordersRepositoryProvider));
});