import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/login_response_dto.dart';
import '../models/register_response_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponseDto> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'emailOrPhone': emailOrPhone, 'password': password},
    );

    final apiResponse = ApiResponse<LoginResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => LoginResponseDto.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          data: {'message': apiResponse.message},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    if (apiResponse.data == null) {
      throw Exception('تعذر قراءة بيانات تسجيل الدخول من الخادم.');
    }

    return apiResponse.data!;
  }

  Future<RegisterResponseDto> register({
    required String fullName,
    required String password,
    required String confirmPassword,
    String? email,
    String? phone,
    String? whatsApp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'phone': phone,
        'whatsApp': whatsApp,
      },
    );

    final apiResponse = ApiResponse<RegisterResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => RegisterResponseDto.fromJson(json as Map<String, dynamic>),
    );
    if (!apiResponse.success) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.register),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.register),
          data: {'message': apiResponse.message},
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    if (apiResponse.data == null) {
      throw Exception('تعذر قراءة بيانات التسجيل من الخادم.');
    }

    return apiResponse.data!;
  }
}
