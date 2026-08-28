import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_response_dto.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(this._remote, this._secureStorage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  @override
  Future<Result<LoginResponseDto>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final result = await _remote.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      await _secureStorage.saveSession(
        token: result.token,
        role: result.role.name,
        userId: result.userId,
        fullName: result.fullName,
      );

      return Success(result);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('AuthRepository', e, st, 'فشل غير متوقع أثناء تسجيل الدخول');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<int>> register({
    required String fullName,
    required String password,
    required String confirmPassword,
    String? email,
    String? phone,
    String? whatsApp,
  }) async {
    try {
      final result = await _remote.register(
        fullName: fullName,
        password: password,
        confirmPassword: confirmPassword,
        email: email,
        phone: phone,
        whatsApp: whatsApp,
      );
      return Success(result.userId);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('AuthRepository', e, st, 'فشل غير متوقع أثناء التسجيل');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<void> logout() => _secureStorage.clearSession();

  @override
  Future<bool> hasActiveSession() => _secureStorage.hasActiveSession();
}