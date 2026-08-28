class ConcreteTypeDto {
  final int concreteTypeId;
  final int factoryId;
  final String name;
  final int strength;
  final double unitPrice;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final String factoryName;

  ConcreteTypeDto({
    required this.concreteTypeId,
    required this.factoryId,
    required this.name,
    required this.strength,
    required this.unitPrice,
    required this.imageUrl,
    required this.description,
    required this.isActive,
    required this.factoryName,
  });

  factory ConcreteTypeDto.fromJson(Map<String, dynamic> json) {
    return ConcreteTypeDto(
      concreteTypeId: json['concreteTypeId'] as int,
      factoryId: json['factoryId'] as int,
      name: json['name'] as String,
      strength: json['strength'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      factoryName: json['factoryName'] as String,
    );
  }
}