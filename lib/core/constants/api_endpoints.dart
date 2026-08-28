class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String register = '/api/Auth/register';
  static const String login = '/api/Auth/login';

  // ---- Factories ----
  static const String factories = '/api/Factories';
  static String factoryById(int id) => '/api/Factories/$id';

  // ---- ConcreteTypes ----
  static const String concreteTypes = '/api/ConcreteTypes';
  static String concreteTypeById(int id) => '/api/ConcreteTypes/$id';

  // ---- Orders ----
  static const String orders = '/api/Orders';
  static String orderById(int id) => '/api/Orders/$id';
  static const String phoneOrder = '/api/Orders/phone-order';
  static String setPrice(int id) => '/api/Orders/$id/price';
  static String approveOrder(int id) => '/api/Orders/$id/approve';
  static String updateOrderStatus(int id) => '/api/Orders/$id/status';
  static String assignDriver(int id) => '/api/Orders/$id/assign-driver';
  static String startDelivery(int id) => '/api/Orders/$id/start-delivery';
  static String deliverOrder(int id) => '/api/Orders/$id/deliver';
  static String closeOrder(int id) => '/api/Orders/$id/close';
  static String rejectOrder(int id) => '/api/Orders/$id/reject';
  static String cancelOrder(int id) => '/api/Orders/$id/cancel';

  // ---- Users ----
  static const String users = '/api/Users';
  static String userById(int id) => '/api/Users/$id';
  static const String myProfile = '/api/Users/me';
  static String driverStatus(int id) => '/api/Users/$id/driver-status';
}