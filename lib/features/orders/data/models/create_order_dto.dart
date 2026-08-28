import '../../../../core/utils/api_enums.dart';

class CreateOrderDto {
  final int clientId;
  final int factoryId;
  final int concreteTypeId;
  final String? projectName;
  final String? projectOwnerName;
  final String? siteArea;
  final String? siteDescription;
  final SlabType slabType;
  final double quantity;
  final bool needPump;
  final int? floorNumber;
  final DateTime? pouringDate;
  final TransportMethod transportMethod;
  final String? notes;

  CreateOrderDto({
    required this.clientId,
    required this.factoryId,
    required this.concreteTypeId,
    this.projectName,
    this.projectOwnerName,
    this.siteArea,
    this.siteDescription,
    required this.slabType,
    required this.quantity,
    required this.needPump,
    this.floorNumber,
    this.pouringDate,
    required this.transportMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'factoryId': factoryId,
      'concreteTypeId': concreteTypeId,
      'projectName': projectName,
      'projectOwnerName': projectOwnerName,
      'siteArea': siteArea,
      'siteDescription': siteDescription,
      'slabType': slabType.toApiValue(),
      'quantity': quantity,
      'needPump': needPump,
      'floorNumber': floorNumber,
      'pouringDate': pouringDate?.toIso8601String(),
      'transportMethod': transportMethod.toApiValue(),
      'notes': notes,
    };
  }
}