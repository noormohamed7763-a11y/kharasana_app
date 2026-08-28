import '../../../../core/utils/api_enums.dart';

class LoginResponseDto {
  final int userId;
  final String fullName;
  final String? email;
  final UserRole role;
  final int? factoryId;
  final String token;
  final DateTime expiration;

  LoginResponseDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.factoryId,
    required this.token,
    required this.expiration,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      role: UserRole.fromApiString(json['role'] as String),
      factoryId: json['factoryId'] as int?,
      token: json['token'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
    );
  }
}