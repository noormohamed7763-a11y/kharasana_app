import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/factory_dto.dart';

class FactoriesRemoteDataSource {
  FactoriesRemoteDataSource(this._dio);
  final Dio _dio;

  /// لا `try/catch` هنا: كان الجسم كلّه ملفوفاً في
  /// `throw Exception('حدث خطأ في تحميل المصانع: $e')`، فيُمحى نوع
  /// `DioException` قبل أن يراه `mapDioError`، ثم يلفّه المزوّد مرّة ثانية.
  /// تحويل الخطأ مسؤولية `guardFailure` في المزوّد، تماماً كأنواع الخرسانة.
  Future<List<FactoryDto>> getFactories() async {
    final response = await _dio.get(ApiEndpoints.factories);
    final apiResponse = ApiResponse<List<FactoryDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => FactoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return apiResponse.data ?? <FactoryDto>[];
  }
}
