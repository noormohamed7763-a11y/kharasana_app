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
import '../../features/concrete_types/data/models/concrete_type_dto.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';

// ✅ استيراد ملفات Users
import '../../features/users/data/datasources/users_remote_data_source.dart';
import '../../features/users/data/repositories/profile_repository_impl.dart';
import '../../features/users/domain/repositories/profile_repository.dart';

// ============================================================
// 🔐 Storage Providers
// ============================================================
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  throw UnimplementedError('يُهيَّأ في main.dart');
});

// ============================================================
// 🌐 Network Providers
// ============================================================
final dioClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage).dio;
});

// ============================================================
// 🔑 Auth Providers
// ============================================================
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

// ============================================================
// 🏭 Factories Providers
// ============================================================
final factoriesRemoteDataSourceProvider = Provider<FactoriesRemoteDataSource>((ref) {
  return FactoriesRemoteDataSource(ref.watch(dioClientProvider));
});

// ============================================================
// 🧱 Concrete Types Providers
// ============================================================
final concreteTypesRemoteDataSourceProvider =
    Provider<ConcreteTypesRemoteDataSource>((ref) {
  return ConcreteTypesRemoteDataSource(ref.watch(dioClientProvider));
});

// ============================================================
// 📦 Orders Providers
// ============================================================
final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSource(ref.watch(dioClientProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.watch(ordersRemoteDataSourceProvider));
});

// ============================================================
// 👤 Users / Profile Providers
// ============================================================
final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSource(ref.watch(dioClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(usersRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

// ============================================================
// 👤 Session User Provider (من التخزين المحلي)
// ============================================================
final sessionUserProvider = FutureProvider.autoDispose<SessionUser>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final userId = await storage.readUserId();
  final fullName = await storage.readFullName();
  final role = await storage.readRole();
  return SessionUser(userId: userId, fullName: fullName, role: role);
});

// ============================================================
// 📋 Simple Data Providers (تستخدم في الشاشات)
// ============================================================
final factoriesListProvider = FutureProvider.autoDispose((ref) async {
  try {
    final dataSource = ref.watch(factoriesRemoteDataSourceProvider);
    final factories = await dataSource.getFactories().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('انتهت مهلة تحميل المصانع'),
    );
    return factories.where((f) => f.isActive).toList();
  } catch (e) {
    throw Exception('حدث خطأ في تحميل المصانع: $e');
  }
});

final concreteTypesListProvider = FutureProvider.autoDispose((ref) async {
  final dataSource = ref.watch(concreteTypesRemoteDataSourceProvider);
  final types = await dataSource.getConcreteTypes();
  return types.where((t) => t.isActive).toList();
});

/// أنواع الخرسانة التابعة لمصنع واحد.
///
/// الخادم لا يوفّر مساراً لأنواع مصنع بعينه (`/api/ConcreteTypes` تُرجع الكل)،
/// فنُرشِّح القائمة محلياً بـ `factoryId`. عرض كل الأنواع للعميل يجعله يطلب
/// نوعاً لا يوفّره المصنع المختار.
final concreteTypesByFactoryProvider = FutureProvider.autoDispose
    .family<List<ConcreteTypeDto>, int>((ref, factoryId) async {
  final types = await ref.watch(concreteTypesListProvider.future);
  return types.where((t) => t.factoryId == factoryId).toList();
});
