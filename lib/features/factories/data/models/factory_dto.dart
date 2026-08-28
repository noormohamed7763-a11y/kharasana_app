class FactoryDto {
  final int factoryId;
  final String factoryName;
  final String? ownerName;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String? area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? logo;
  final bool isActive;
  final bool hasAccount;

  FactoryDto({
    required this.factoryId,
    required this.factoryName,
    required this.ownerName,
    required this.phone,
    required this.whatsApp,
    required this.email,
    required this.area,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.logo,
    required this.isActive,
    required this.hasAccount,
  });

  factory FactoryDto.fromJson(Map<String, dynamic> json) {
    return FactoryDto(
      factoryId: json['factoryId'] as int,
      factoryName: json['factoryName'] as String,
      ownerName: json['ownerName'] as String?,
      phone: json['phone'] as String?,
      whatsApp: json['whatsApp'] as String?,
      email: json['email'] as String?,
      area: json['area'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      logo: json['logo'] as String?,
      isActive: json['isActive'] as bool,
      hasAccount: json['hasAccount'] as bool,
    );
  }
}