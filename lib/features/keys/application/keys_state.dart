import '../data/api_key_model.dart';

enum KeysStatus { initial, loading, loaded, error }

class KeysState {
  final KeysStatus status;
  final List<ApiKeyEntry> keys;
  final String? error;

  /// کلید تازه‌ساخته‌شده برای نمایش یک‌باره به کاربر
  final ApiKeyEntry? newlyCreated;

  const KeysState({
    this.status = KeysStatus.initial,
    this.keys = const [],
    this.error,
    this.newlyCreated,
  });

  KeysState copyWith({
    KeysStatus? status,
    List<ApiKeyEntry>? keys,
    String? error,
    ApiKeyEntry? newlyCreated,
    bool clearNewlyCreated = false,
    bool clearError = false,
  }) {
    return KeysState(
      status: status ?? this.status,
      keys: keys ?? this.keys,
      error: clearError ? null : (error ?? this.error),
      newlyCreated:
          clearNewlyCreated ? null : (newlyCreated ?? this.newlyCreated),
    );
  }
}
