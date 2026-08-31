import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../storage/secure_storage_service.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/client/presentation/screens/client_home_screen.dart';
import '../../features/client/presentation/screens/client_profile_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_order_details_screen.dart';
import '../../features/driver/presentation/screens/driver_profile_screen.dart';
import '../../features/factories/presentation/screens/factories_list_screen.dart';
import '../../features/orders/presentation/screens/create_order_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';

/// قرار التوجيه بحسب الجلسة والدور.
///
/// مُخرَج من [buildRouter] ليكون قابلاً للاختبار وحدةً: كسر هذه القواعد
/// ثغرة أمنية لا خلل واجهة. انظر `test/auth_redirect_test.dart`.
///
/// يُرجع المسار المطلوب التوجيه إليه، أو `null` للسماح بالمسار كما هو.
@visibleForTesting
Future<String?> resolveAuthRedirect(
  SecureStorageService secureStorage,
  String matchedLocation,
) async {
  // نسمح بالوصول إلى splash دائماً
  if (matchedLocation == AppRoutes.splash) return null;

  final hasSession = await secureStorage.hasActiveSession();
  final isAuthRoute =
      matchedLocation == AppRoutes.login || matchedLocation == AppRoutes.register;

  // إذا لم يكن هناك جلسة والمستخدم يحاول الوصول إلى صفحة محمية
  if (!hasSession && !isAuthRoute) {
    return AppRoutes.login;
  }

  // إذا كانت هناك جلسة والمستخدم يحاول الوصول إلى login أو register
  if (hasSession && isAuthRoute) {
    final role = await secureStorage.readRole();
    if (role == 'driver') {
      return AppRoutes.driverHome;
    } else {
      return AppRoutes.clientHome;
    }
  }

  // منع Client من الوصول إلى Driver routes والعكس
  if (hasSession) {
    final role = await secureStorage.readRole();
    final goingToDriver = matchedLocation.startsWith('/driver');
    final goingToClient = matchedLocation.startsWith('/client');

    if (role == 'driver' && goingToClient) {
      return AppRoutes.driverHome;
    }
    if (role == 'client' && goingToDriver) {
      return AppRoutes.clientHome;
    }
  }

  return null;
}

GoRouter buildRouter(SecureStorageService secureStorage) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) =>
        resolveAuthRedirect(secureStorage, state.matchedLocation),
    routes: [
      // ============================================================
      // Auth Routes
      // ============================================================
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ============================================================
      // Client Routes
      // ============================================================
      GoRoute(
        path: AppRoutes.clientHome,
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientFactories,
        builder: (context, state) => const FactoriesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientOrders,
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientOrderCreate,
        builder: (context, state) {
          final factoryIdParam = state.uri.queryParameters['factoryId'];
          return CreateOrderScreen(
            initialFactoryId: factoryIdParam != null ? int.tryParse(factoryIdParam) : null,
          );
        },
      ),
      // ملاحظة: يجب أن يبقى هذا المسار بعد clientOrderCreate،
      // وإلا طابق go_router الكلمة "create" على :id
      GoRoute(
        path: AppRoutes.clientOrderDetails,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('رقم طلب غير صالح')),
            );
          }
          return OrderDetailsScreen(orderId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.clientProfile,
        builder: (context, state) => const ClientProfileScreen(),
      ),

      // ============================================================
      // Driver Routes
      // ============================================================
      GoRoute(
        path: AppRoutes.driverHome,
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverProfile,
        builder: (context, state) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverOrderDetails,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('رقم طلب غير صالح')),
            );
          }
          return DriverOrderDetailsScreen(orderId: id);
        },
      ),
      // TODO: GoRoute(path: AppRoutes.driverOrders, ...)
    ],
  );
}