import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../session/session_user.dart';
import '../storage/secure_storage_service.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/factories/data/datasources/factories_remote_data_source.dart';
import '../../features/concrete_types/data/datasources/concrete_types_remote_data_source.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/users/data/datasources/users_remote_data_source.dart';
import '../../features/users/data/repositories/profile_repository_impl.dart';
import '../../features/users/domain/repositories/profile_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  throw UnimplementedError('يُهيَّأ في main.dart');
});

final dioClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage).dio;
});

// ---- Auth ----
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

// ---- Factories ----
final factoriesRemoteDataSourceProvider = Provider<FactoriesRemoteDataSource>((ref) {
  return FactoriesRemoteDataSource(ref.watch(dioClientProvider));
});

// ---- ConcreteTypes ----
final concreteTypesRemoteDataSourceProvider =
    Provider<ConcreteTypesRemoteDataSource>((ref) {
  return ConcreteTypesRemoteDataSource(ref.watch(dioClientProvider));
});

// ---- Orders ----
final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSource(ref.watch(dioClientProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.watch(ordersRemoteDataSourceProvider));
});

// ---- Users / Profile ----
final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSource(ref.watch(dioClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(usersRemoteDataSourceProvider));
});

/// بيانات المستخدم المسجَّل دخوله حالياً، من التخزين الآمن.
///
/// ⚠️ لا نستخدم الخادم هنا: `GET /api/Users/me` يُعيد 405 و
/// `GET /api/Users/{id}` يُعيد 403 لدور Driver — راجع [SessionUser].
final sessionUserProvider = FutureProvider.autoDispose<SessionUser>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final userId = await storage.readUserId();
  final fullName = await storage.readFullName();
  final role = await storage.readRole();
  return SessionUser(userId: userId, fullName: fullName, role: role);
});

// ---- Simple data providers ----
final factoriesListProvider = FutureProvider.autoDispose((ref) async {
  final dataSource = ref.watch(factoriesRemoteDataSourceProvider);
  final factories = await dataSource.getFactories();
  return factories.where((f) => f.isActive).toList();
});

final concreteTypesListProvider = FutureProvider.autoDispose((ref) async {
  final dataSource = ref.watch(concreteTypesRemoteDataSourceProvider);
  final types = await dataSource.getConcreteTypes();
  return types.where((t) => t.isActive).toList();
});