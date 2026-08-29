import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/api_enums.dart';
import '../models/user_dto.dart';

class UsersRemoteDataSource {
  UsersRemoteDataSource(this._dio);
  final Dio _dio;

  // ============================================================
  // ✅ جلب مستخدم بواسطة ID
  // ============================================================
  Future<UserDto> getUserById(int id) async {
    final response = await _dio.get(ApiEndpoints.userById(id));
    final apiResponse = ApiResponse<UserDto?>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => json != null ? UserDto.fromJson(json as Map<String, dynamic>) : null,
    );
    
    if (apiResponse.data == null) {
      throw Exception('المستخدم غير موجود');
    }
    
    return apiResponse.data!;
  }

  // ============================================================
  // ✅ تحديث الملف الشخصي (نفسي)
  // ============================================================
  Future<void> updateMyProfile({
    String? fullName,
    String? phone,
    String? whatsApp,
  }) async {
    await _dio.put(
      ApiEndpoints.myProfile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (whatsApp != null) 'whatsApp': whatsApp,
      },
    );
  }

  // ============================================================
  // 🚫 غير قابل للاستخدام مع الخادم الحالي
  // ============================================================
  Future<UserDto> getMyProfile() async {
    final response = await _dio.get(ApiEndpoints.myProfile);
    final apiResponse = ApiResponse<UserDto>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => UserDto.fromJson(json as Map<String, dynamic>),
    );
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.myProfile),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.myProfile),
          data: {'message': apiResponse.message},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    if (apiResponse.data == null) {
      throw Exception('تعذر قراءة بيانات المستخدم من الخادم.');
    }

    return apiResponse.data!;
  }

  // ============================================================
  // ✅ تحديث حالة السائق
  // ============================================================
  Future<void> updateDriverStatus(int userId, DriverStatus status) async {
    await _dio.put(
      ApiEndpoints.driverStatus(userId),
      data: {'driverStatus': status.toApiValue()},
    );
  }
}