import '../../../../core/utils/api_enums.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserRole role;
  const AuthAuthenticated(this.role);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthRegistered extends AuthState {
  const AuthRegistered();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}