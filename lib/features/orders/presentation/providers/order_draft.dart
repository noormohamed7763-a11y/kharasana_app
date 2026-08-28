import '../../../../core/utils/api_enums.dart';

/// حالة النموذج غير القابلة للتغيير
class OrderDraft {
  final int? factoryId;
  final String? factoryName;
  final int? concreteTypeId;
  final String? concreteTypeName;
  final double? concreteUnitPrice;
  final String? projectName;
  final String? projectOwnerName;
  final String? siteArea;
  final String? siteDescription;
  final SlabType slabType;
  final double? quantity;
  final bool needPump;
  final int? floorNumber;
  final DateTime? pouringDate;
  final TransportMethod transportMethod;
  final String? notes;

  const OrderDraft({
    this.factoryId,
    this.factoryName,
    this.concreteTypeId,
    this.concreteTypeName,
    this.concreteUnitPrice,
    this.projectName,
    this.projectOwnerName,
    this.siteArea,
    this.siteDescription,
    this.slabType = SlabType.foundation,
    this.quantity,
    this.needPump = false,
    this.floorNumber,
    this.pouringDate,
    this.transportMethod = TransportMethod.factoryTransport,
    this.notes,
  });

  double? get estimatedTotal =>
      (quantity != null && concreteUnitPrice != null) 
          ? quantity! * concreteUnitPrice! 
          : null;

  OrderDraft copyWith({
    int? factoryId,
    String? factoryName,
    int? concreteTypeId,
    String? concreteTypeName,
    double? concreteUnitPrice,
    String? projectName,
    String? projectOwnerName,
    String? siteArea,
    String? siteDescription,
    SlabType? slabType,
    double? quantity,
    bool? needPump,
    int? floorNumber,
    bool clearFloorNumber = false,
    DateTime? pouringDate,
    TransportMethod? transportMethod,
    String? notes,
  }) {
    return OrderDraft(
      factoryId: factoryId ?? this.factoryId,
      factoryName: factoryName ?? this.factoryName,
      concreteTypeId: concreteTypeId ?? this.concreteTypeId,
      concreteTypeName: concreteTypeName ?? this.concreteTypeName,
      concreteUnitPrice: concreteUnitPrice ?? this.concreteUnitPrice,
      projectName: projectName ?? this.projectName,
      projectOwnerName: projectOwnerName ?? this.projectOwnerName,
      siteArea: siteArea ?? this.siteArea,
      siteDescription: siteDescription ?? this.siteDescription,
      slabType: slabType ?? this.slabType,
      quantity: quantity ?? this.quantity,
      needPump: needPump ?? this.needPump,
      floorNumber: clearFloorNumber ? null : (floorNumber ?? this.floorNumber),
      pouringDate: pouringDate ?? this.pouringDate,
      transportMethod: transportMethod ?? this.transportMethod,
      notes: notes ?? this.notes,
    );
  }

  bool get isFactoryAndTypeValid => factoryId != null && concreteTypeId != null;
  bool get isSiteAndTechnicalValid =>
      quantity != null && quantity! > 0 && (!needPump || floorNumber != null);
  bool get isReadyToSubmit => isFactoryAndTypeValid && isSiteAndTechnicalValid;
}