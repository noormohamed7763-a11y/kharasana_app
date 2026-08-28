import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/concrete_type_dto.dart';

class ConcreteTypesRemoteDataSource {
  ConcreteTypesRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<ConcreteTypeDto>> getConcreteTypes() async {
    final response = await _dio.get(ApiEndpoints.concreteTypes);
    final apiResponse = ApiResponse<List<ConcreteTypeDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => ConcreteTypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return apiResponse.data ?? <ConcreteTypeDto>[];
  }
}