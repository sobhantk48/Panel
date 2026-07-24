import '../../../core/api/models/auth_response.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthResponse? authResponse;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authResponse,
    this.errorMessage,
  });

  bool get isMasterKey => authResponse?.isMasterKey ?? false;

  AuthState copyWith({
    AuthStatus? status,
    AuthResponse? authResponse,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authResponse: authResponse ?? this.authResponse,
      errorMessage: errorMessage,
    );
  }
}
