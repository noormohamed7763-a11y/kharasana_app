import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/users_remote_data_source.dart';
import '../models/user_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(
    this._remote,
    this._secureStorage,
  );

  final UsersRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  @override
  Future<Result<UserDto>> getMyProfile() async {
    try {
      final userId = await _secureStorage.readUserId();
      if (userId == null) {
        return const Error(UnauthorizedFailure());
      }
      final user = await _remote.getUserById(userId);
      return Success(user);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('ProfileRepository', e, st, 'فشل غير متوقع أثناء جلب الملف الشخصي');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> updateDriverStatus(
    int userId,
    DriverStatus status,
  ) async {
    try {
      await _remote.updateDriverStatus(userId, status);
      return const Success(null);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('ProfileRepository', e, st, 'فشل غير متوقع أثناء تغيير حالة السائق');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> updateMyProfile({
    String? fullName,
    String? phone,
    String? whatsApp,
  }) async {
    try {
      await _remote.updateMyProfile(
        fullName: fullName,
        phone: phone,
        whatsApp: whatsApp,
      );
      return const Success(null);
    } on DioException catch (e) {
      return Error(mapDioError(e));
    } catch (e, st) {
      AppLogger.error('ProfileRepository', e, st, 'فشل غير متوقع أثناء تحديث الملف الشخصي');
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearSession();
  }
}