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
  static const clientFactoryDetails = '/client/factories/:id';
  static const clientOrders = '/client/orders';
  static const clientOrderCreate = '/client/orders/create';
  static const clientOrderDetails = '/client/orders/:id';
  static const clientProfile = '/client/profile';

  // ============================================================
  // Driver Routes
  // ============================================================
  static const driverHome = '/driver/home';
  static const driverOrders = '/driver/orders';
  static const driverOrderDetails = '/driver/orders/:id';
  static const driverProfile = '/driver/profile';
}