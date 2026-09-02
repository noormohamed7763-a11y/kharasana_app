/// مسارات التطبيق.
///
/// كلّ ثابت هنا يقابله `GoRoute` في [buildRouter]. حُذف من هذه القائمة
/// ثابتان لا وجود لمساريهما (`/client/factories/:id` و`/driver/orders`):
/// استدعاء أيّ منهما كان يُنتج شاشة خطأ «no routes for location».
class AppRoutes {
  AppRoutes._();

  // ============================================================
  // Auth Routes
  // ============================================================
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // ============================================================
  // Client Routes
  // ============================================================
  static const clientHome = '/client/home';
  static const clientFactories = '/client/factories';
  static const clientOrders = '/client/orders';
  static const clientOrderCreate = '/client/orders/create';
  static const clientOrderDetails = '/client/orders/:id';
  static const clientProfile = '/client/profile';

  // ============================================================
  // Driver Routes
  // ============================================================
  static const driverHome = '/driver/home';
  static const driverOrderDetails = '/driver/orders/:id';
  static const driverProfile = '/driver/profile';
}