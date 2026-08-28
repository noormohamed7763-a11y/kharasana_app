import '../../../../core/utils/api_enums.dart';

class OrderSummaryDto {
  final int orderId;
  final String orderNumber;
  final String clientName;
  final String factoryName;
  final String concreteTypeName;
  final double quantity;

  /// السعر الإجمالي — `null` عندما لم يُسعَّر الطلب بعد من قِبل المصنع.
  /// الخادم يُرجع `"totalPrice": null` في هذه الحالة.
  final double? totalPrice;
  final TransportMethod transportMethod;
  final OrderStatus status;
  final DateTime? createdAt;

  OrderSummaryDto({
    required this.orderId,
    required this.orderNumber,
    required this.clientName,
    required this.factoryName,
    required this.concreteTypeName,
    required this.quantity,
    this.totalPrice,
    required this.transportMethod,
    required this.status,
    required this.createdAt,
  });

  factory OrderSummaryDto.fromJson(Map<String, dynamic> json) {
    return OrderSummaryDto(
      orderId: json['orderId'] as int,
      orderNumber: json['orderNumber'] as String,
      clientName: json['clientName'] as String,
      factoryName: json['factoryName'] as String,
      concreteTypeName: json['concreteTypeName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      transportMethod: TransportMethod.fromApiValue(json['transportMethod'] as int),
      status: OrderStatus.fromApiValue(json['status'] as String),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) 
          : null,
    );
  }
}