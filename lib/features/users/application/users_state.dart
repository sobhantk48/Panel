import '../data/user_model.dart';

enum UsersStatus { initial, loading, loaded, error }

class UsersState {
  final UsersStatus status;
  final List<NahanUser> users;
  final String? error;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.error,
  });

  UsersState copyWith({UsersStatus? status, List<NahanUser>? users, String? error}) =>
      UsersState(
        status: status ?? this.status,
        users: users ?? this.users,
        error: error,
      );
}
