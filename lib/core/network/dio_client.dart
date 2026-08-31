import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/failure.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

class DioClient {
  DioClient(this._secureStorage) {
    // ============================================================
    // ✅ استخدام الرابط المتغير (getter) بدلاً من الثابت
    // ============================================================
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

/// ✅ دالة محسّنة لمعالجة أخطاء Dio
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
      final data = e.response?.data as Map<String, dynamic>?;

      switch (status) {
        case 400:
          // ✅ معالجة أخطاء التحقق (Validation)
          if (data != null) {
            final message = _extractMessage(data);
            final fieldErrors = _extractFieldErrors(data);
            if (fieldErrors != null && fieldErrors.isNotEmpty) {
              // عرض أخطاء الحقول بشكل مفصل
              final errorsList = fieldErrors.values.expand((e) => e).join('\n');
              return ValidationFailure(errorsList, fieldErrors: fieldErrors);
            }
            if (message != null) {
              return ValidationFailure(message);
            }
          }
          return ValidationFailure('البيانات المدخلة غير صحيحة.');

        case 401:
          return const UnauthorizedFailure();
        case 403:
          return const ForbiddenFailure();
        case 404:
          return const NotFoundFailure();
        case 409:
          return ValidationFailure('البريد الإلكتروني أو رقم الهاتف مسجل بالفعل.');
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

/// ✅ استخراج رسالة الخطأ من الاستجابة
String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message']?.toString() ?? data['title']?.toString();
  }
  return null;
}

/// ✅ استخراج أخطاء الحقول من الاستجابة
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

/// ✅ معالجة الأخطاء غير المتوقعة (مثل أخطاء التحويل من JSON)
Failure mapUnexpectedError(Object error, StackTrace stackTrace) {
  AppLogger.error('DataLayer', error, stackTrace, 'خطأ غير متوقع في طبقة البيانات');
  if (error is TypeError) {
    return const ParseFailure('خطأ في قراءة البيانات من الخادم.');
  }
  return const UnknownFailure();
}