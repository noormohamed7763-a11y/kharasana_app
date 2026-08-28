class RegisterResponseDto {
  final int userId;
  RegisterResponseDto({required this.userId});

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(userId: json['userId'] as int);
  }
}