import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/utils/api_enums.dart';
import 'package:kharasana_app/features/orders/data/models/order_summary_dto.dart';

/// استجابة حقيقية من `GET /api/Orders` بحساب سائق (تم نسخها كما هي من الخادم).
/// لاحظ `"totalPrice": null` — طلب تمت الموافقة عليه لكن لم يُسعَّر بعد.
/// كان هذا الحقل غير قابل لـ null في الـ DTO، فيرمي `TypeError` عند التحليل،
/// فتظهر شاشة السائق فارغة بلا سبب واضح.
const _driverOrdersJson = '''
{
  "success": true,
  "message": "تم جلب جميع الطلبات بنجاح.",
  "data": {
    "items": [
      {
        "orderId": 30,
        "orderNumber": "ORD-20260825-5392FE54",
        "clientName": "قاسم هزاع",
        "factoryName": "مصنع الامل",
        "concreteTypeName": "C30",
        "quantity": 19.70,
        "totalPrice": null,
        "transportMethod": 0,
        "status": "Approved",
        "createdAt": "2026-08-25T21:54:39.6223731"
      }
    ],
    "pageNumber": 1,
    "pageSize": 20,
    "totalCount": 1,
    "totalPages": 1
  }
}
''';

void main() {
  group('OrderSummaryDto.fromJson', () {
    test('يحلّل طلباً غير مسعَّر (totalPrice = null) دون رمي استثناء', () {
      final decoded = jsonDecode(_driverOrdersJson) as Map<String, dynamic>;
      final items = (decoded['data'] as Map<String, dynamic>)['items'] as List;

      final order =
          OrderSummaryDto.fromJson(items.first as Map<String, dynamic>);

      expect(order.orderId, 30);
      expect(order.orderNumber, 'ORD-20260825-5392FE54');
      expect(order.clientName, 'قاسم هزاع');
      expect(order.factoryName, 'مصنع الامل');
      expect(order.concreteTypeName, 'C30');
      expect(order.quantity, 19.7);
      expect(order.totalPrice, isNull);
      expect(order.status, OrderStatus.approved);
      expect(order.transportMethod, TransportMethod.fromApiValue(0));
      expect(order.createdAt, isNotNull);
    });

    test('يحلّل طلباً مسعَّراً بشكل صحيح', () {
      final order = OrderSummaryDto.fromJson({
        'orderId': 31,
        'orderNumber': 'ORD-20260825-AAAA',
        'clientName': 'عميل',
        'factoryName': 'مصنع',
        'concreteTypeName': 'C25',
        'quantity': 10,
        'totalPrice': 250000,
        'transportMethod': 0,
        'status': 'Delivered',
        'createdAt': null,
      });

      expect(order.totalPrice, 250000.0);
      expect(order.status, OrderStatus.delivered);
      expect(order.createdAt, isNull);
    });
  });
}
