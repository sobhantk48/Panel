import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthNotifier(this._apiClient, this._storage) : super(const AuthState());

  /// موقع باز شدن اپ صدا زده میشه: چک می‌کنه قبلاً وارد شده یا نه.
  /// چون /api/auth استیت‌لس هست، دوباره با همون کلید ذخیره‌شده لاگین می‌کنیم
  /// تا هم اعتبار کلید تایید بشه هم داده‌ی تازه بیاد.
  Future<void> checkSavedSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasCreds = await _storage.hasCredentials();
      if (!hasCreds) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final baseUrl = await _storage.getBaseUrl();
      final apiRoute =
          await _storage.getApiRoute() ?? ApiConstants.defaultApiRoute;
      final apiKey = await _storage.getApiKey();

      if (baseUrl == null || apiKey == null) {
        await _storage.clear();
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final auth = await _apiClient.login(
        baseUrl: baseUrl,
        apiRoute: apiRoute,
        key: apiKey,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        authResponse: auth,
      );
    } catch (e) {
      await _storage.clear();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login({
    required String baseUrl,
    required String apiRoute,
    required String key,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );
    try {
      final auth = await _apiClient.login(
        baseUrl: baseUrl,
        apiRoute: apiRoute,
        key: key,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        authResponse: auth,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
