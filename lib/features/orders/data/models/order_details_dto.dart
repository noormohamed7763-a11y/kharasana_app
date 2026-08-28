import '../../../../core/utils/api_enums.dart';

class OrderDetailsDto {
  final int orderId;
  final String orderNumber;
  final int clientId;
  final String clientName;
  final String? clientPhone;
  final int factoryId;
  final String factoryName;
  final int concreteTypeId;
  final String concreteTypeName;
  final String? projectName;
  final String? projectOwnerName;
  final String? siteArea;
  final String? siteDescription;
  final SlabType slabType;
  final double quantity;
  final bool needPump;
  final int? floorNumber;
  final double? unitPrice;
  final double? totalPrice;
  final DateTime? pouringDate;
  final TransportMethod transportMethod;
  final int? driverId;
  final String? driverName;
  final String? truckPlate;
  final OrderStatus status;
  final String? notes;

  OrderDetailsDto({
    required this.orderId,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.factoryId,
    required this.factoryName,
    required this.concreteTypeId,
    required this.concreteTypeName,
    this.projectName,
    this.projectOwnerName,
    this.siteArea,
    this.siteDescription,
    required this.slabType,
    required this.quantity,
    required this.needPump,
    this.floorNumber,
    this.unitPrice,
    this.totalPrice,
    this.pouringDate,
    required this.transportMethod,
    this.driverId,
    this.driverName,
    this.truckPlate,
    required this.status,
    this.notes,
  });

  bool get isPriced => unitPrice != null;
  bool get hasDriverAssigned => driverId != null;

  factory OrderDetailsDto.fromJson(Map<String, dynamic> json) {
    return OrderDetailsDto(
      orderId: json['orderId'] as int,
      orderNumber: json['orderNumber'] as String,
      clientId: json['clientId'] as int,
      clientName: json['clientName'] as String,
      clientPhone: json['clientPhone'] as String?,
      factoryId: json['factoryId'] as int,
      factoryName: json['factoryName'] as String,
      concreteTypeId: json['concreteTypeId'] as int,
      concreteTypeName: json['concreteTypeName'] as String,
      projectName: json['projectName'] as String?,
      projectOwnerName: json['projectOwnerName'] as String?,
      siteArea: json['siteArea'] as String?,
      siteDescription: json['siteDescription'] as String?,
      slabType: SlabType.fromApiValue(json['slabType'] as int),
      quantity: (json['quantity'] as num).toDouble(),
      needPump: json['needPump'] as bool,
      floorNumber: json['floorNumber'] as int?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      pouringDate: json['pouringDate'] != null
          ? DateTime.tryParse(json['pouringDate'] as String)
          : null,
      transportMethod: TransportMethod.fromApiValue(json['transportMethod'] as int),
      driverId: json['driverId'] as int?,
      driverName: json['driverName'] as String?,
      truckPlate: json['truckPlate'] as String?,
      status: OrderStatus.fromApiValue(json['status'] as String),
      notes: json['notes'] as String?,
    );
  }
}