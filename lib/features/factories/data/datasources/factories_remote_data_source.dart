import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/factory_dto.dart';

class FactoriesRemoteDataSource {
  FactoriesRemoteDataSource(this._dio);
  final Dio _dio;

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