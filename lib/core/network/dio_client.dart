import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/failure.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

class DioClient {
  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrlDev,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.apiRequest(options.method, options.path, data: options.data);
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.apiResponse(
            response.requestOptions.method,
            response.requestOptions.path,
            response.statusCode,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.apiError(
            error.requestOptions.method,
            error.requestOptions.path,
            error.response?.statusCode,
            error.response?.data,
          );
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;

  Dio get dio => _dio;
}

Failure mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      switch (status) {
        case 401:
          return const UnauthorizedFailure();
        case 403:
          return const ForbiddenFailure();
        case 404:
          return const NotFoundFailure();
        case 400:
        case 422:
          return ValidationFailure(
            _extractMessage(e.response?.data) ?? 'البيانات المدخلة غير صحيحة.',
            fieldErrors: _extractFieldErrors(e.response?.data),
          );
        case 500:
        default:
          return const ServerFailure();
      }
    case DioExceptionType.cancel:
      return const UnknownFailure();
    default:
      return const UnknownFailure();
  }
}

String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message']?.toString() ?? data['title']?.toString();
  }
  return null;
}

/// يُستخدم في `catch` الأخير داخل المستودعات (repositories) بدلاً من إرجاع
/// `UnknownFailure` صامتة. غالباً يكون السبب `TypeError` من `fromJson`
/// عندما يُرجع الخادم حقلاً بقيمة `null` أو بنوع مختلف عمّا يتوقعه الـ DTO.
Failure mapUnexpectedError(Object error, StackTrace stackTrace) {
  AppLogger.error('DataLayer', error, stackTrace, 'خطأ غير متوقع في طبقة البيانات');
  if (error is TypeError) return ParseFailure(error);
  return const UnknownFailure();
}

Map<String, List<String>>? _extractFieldErrors(dynamic data) {
  if (data is Map<String, dynamic> && data['errors'] is Map) {
    final raw = data['errors'] as Map;
    return raw.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as List).map((e) => e.toString()).toList(),
      ),
    );
  }
  return null;
}