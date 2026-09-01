import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  // ✅ ملاحظة: لا توجد هنا دالة checkSession. كانت موجودة سابقاً لكنها كانت
  // تُرجع AuthUnauthenticated دائماً بلا أي منطق فعلي مختلف عن ذلك،
  // ولا شيء في التطبيق يستدعيها (SplashScreen يقرأ SecureStorageService
  // مباشرة). دالة ميتة تعطي انطباعاً كاذباً بوجود مسار فحص جلسة إضافي.

  Future<void> login(String emailOrPhone, String password) async {
    state = const AuthLoading();
    final result = await _repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    switch (result) {
      case Success(data: final loginData):
        state = AuthAuthenticated(loginData.role);
      case Error(failure: final failure):
        state = AuthError(failure.messageAr);
    }
  }

  Future<void> register({
    required String fullName,
    required String password,
    required String confirmPassword,
    String? email,
    String? phone,
    String? whatsApp,
  }) async {
    state = const AuthLoading();
    final result = await _repository.register(
      fullName: fullName,
      password: password,
      confirmPassword: confirmPassword,
      email: email,
      phone: phone,
      whatsApp: whatsApp,
    );
    switch (result) {
      case Success():
        state = const AuthRegistered();
      case Error(failure: final failure):
        state = AuthError(failure.messageAr);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }
}