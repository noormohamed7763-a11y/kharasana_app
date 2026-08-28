import '../../../../core/utils/result.dart';
import '../../data/models/login_response_dto.dart';

abstract class AuthRepository {
  Future<Result<LoginResponseDto>> login({
    required String emailOrPhone,
    required String password,
  });

  Future<Result<int>> register({
    required String fullName,
    required String password,
    required String confirmPassword,
    String? email,
    String? phone,
    String? whatsApp,
  });

  Future<void> logout();
  Future<bool> hasActiveSession();
}
