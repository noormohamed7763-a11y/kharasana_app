import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/errors/failure.dart';
import 'package:kharasana_app/core/network/api_response.dart';
import 'package:kharasana_app/core/utils/api_enums.dart';
import 'package:kharasana_app/core/utils/result.dart';
import 'package:kharasana_app/features/orders/data/models/create_order_dto.dart';
import 'package:kharasana_app/features/orders/data/models/order_details_dto.dart';
import 'package:kharasana_app/features/orders/data/models/order_summary_dto.dart';
import 'package:kharasana_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:kharasana_app/features/orders/presentation/providers/orders_list_controller.dart';

OrderSummaryDto _order(int id) => OrderSummaryDto(
      orderId: id,
      orderNumber: 'KH-$id',
      clientName: 'عميل',
      factoryName: 'مصنع',
      concreteTypeName: 'C25',
      quantity: 10,
      totalPrice: null,
      transportMethod: TransportMethod.factoryTransport,
      status: OrderStatus.newOrder,
      createdAt: null,
    );

PagedResult<OrderSummaryDto> _page(
  List<int> ids, {
  int pageNumber = 1,
  int totalPages = 1,
}) {
  return PagedResult<OrderSummaryDto>(
    items: ids.map(_order).toList(),
    pageNumber: pageNumber,
    pageSize: 20,
    totalCount: 40,
    totalPages: totalPages,
  );
}

/// مستودع يُحصي النداءات ويؤجّل الردّ حتى نطلبه.
class _FakeRepo implements OrdersRepository {
  _FakeRepo({this.totalPages = 1});

  final int totalPages;
  final List<int> requestedPages = [];
  final List<Completer<Result<PagedResult<OrderSummaryDto>>>> pending = [];

  /// عند `false` يُؤجّل الرد ليُكمَل يدوياً عبر [pending].
  bool respondImmediately = true;

  @override
  Future<Result<PagedResult<OrderSummaryDto>>> getOrders({
    required int pageNumber,
    String? search,
  }) {
    requestedPages.add(pageNumber);
    if (respondImmediately) {
      return Future.value(
        Success(_page([pageNumber * 10], pageNumber: pageNumber, totalPages: totalPages)),
      );
    }
    final completer = Completer<Result<PagedResult<OrderSummaryDto>>>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<Result<int>> createOrder(CreateOrderDto dto) async => const Success(1);
  @override
  Future<Result<OrderDetailsDto>> getOrderById(int id) => throw UnimplementedError();
  @override
  Future<Result<void>> startDelivery(int orderId) async => const Success(null);
  @override
  Future<Result<void>> deliverOrder(int orderId) async => const Success(null);
}

void main() {
  group('OrdersListController — أمان التخلّص', () {
    test('ردّ يصل بعد التخلّص من المزوّد لا يرمي استثناءً', () async {
      // المزوّد `autoDispose`: الخروج من شاشة «طلباتي» قبل وصول الرد كان
      // يُنتج «Bad state: Tried to use OrdersListController after dispose»،
      // لأن `loadFirstPage` تكتب على `state` بعد `await` بلا فحص `mounted`.
      final repo = _FakeRepo()..respondImmediately = false;
      final controller = OrdersListController(repo);

      controller.dispose();

      Object? uncaught;
      await runZonedGuarded(() async {
        repo.pending.single.complete(Success(_page([1])));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      }, (error, _) => uncaught = error);

      expect(uncaught, isNull);
    });

    test('فشل يصل بعد التخلّص لا يرمي استثناءً', () async {
      final repo = _FakeRepo()..respondImmediately = false;
      final controller = OrdersListController(repo);

      controller.dispose();

      Object? uncaught;
      await runZonedGuarded(() async {
        repo.pending.single.complete(const Error(NetworkFailure()));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      }, (error, _) => uncaught = error);

      expect(uncaught, isNull);
    });

    test('صفحة تالية تصل بعد التخلّص لا ترمي استثناءً', () async {
      final repo = _FakeRepo(totalPages: 3);
      final controller = OrdersListController(repo);
      await Future<void>.delayed(Duration.zero);

      repo.respondImmediately = false;
      final loadMore = controller.loadMore();
      controller.dispose();

      Object? uncaught;
      await runZonedGuarded(() async {
        repo.pending.single.complete(Success(_page([2], pageNumber: 2, totalPages: 3)));
        await loadMore;
      }, (error, _) => uncaught = error);

      expect(uncaught, isNull);
    });
  });

  group('OrdersListController — عدد الطلبات الشبكية', () {
    test('الباني يطلب الصفحة الأولى مرة واحدة فقط', () async {
      // شاشة «طلباتي» كانت تنادي `refresh()` في `addPostFrameCallback` فوق
      // نداء الباني، فطلبان شبكيان لكلّ فتح للشاشة.
      final repo = _FakeRepo();
      OrdersListController(repo);
      await Future<void>.delayed(Duration.zero);

      expect(repo.requestedPages, [1]);
    });

    test('loadMore لا يُطلق طلباً حين لا توجد صفحات أخرى', () async {
      final repo = _FakeRepo();
      final controller = OrdersListController(repo);
      await Future<void>.delayed(Duration.zero);

      await controller.loadMore();

      expect(repo.requestedPages, [1]);
    });

    test('loadMore يطلب الصفحة التالية ويضيف عناصرها', () async {
      final repo = _FakeRepo(totalPages: 2);
      final controller = OrdersListController(repo);
      await Future<void>.delayed(Duration.zero);

      await controller.loadMore();

      expect(repo.requestedPages, [1, 2]);
      final state = controller.state as OrdersListLoaded;
      expect(state.items.map((o) => o.orderId), [10, 20]);
      expect(state.isLoadingMore, isFalse);
    });

    test('الفشل يُعرَض برسالة الخطأ العربية لا بنصّ عامّ', () async {
      // `loadFirstPage` كانت ملفوفة في `try/catch` يستبدل كلّ فشل بـ«حدث خطأ
      // أثناء تحميل الطلبات»، فتضيع رسالة `Failure` الدقيقة.
      final repo = _FakeRepo()..respondImmediately = false;
      final controller = OrdersListController(repo);

      repo.pending.single.complete(const Error(UnauthorizedFailure()));
      await Future<void>.delayed(Duration.zero);

      expect(
        (controller.state as OrdersListError).message,
        const UnauthorizedFailure().messageAr,
      );
    });
  });
}
