import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/users/data/users_repository.dart';
import '../../features/users/application/users_notifier.dart';
import '../../features/users/application/users_state.dart';
import '../../features/dashboard/data/stats_repository.dart';
import '../../features/dashboard/application/stats_notifier.dart';
import '../../features/dashboard/application/stats_state.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.read(secureStorageProvider)),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(apiClientProvider), ref.read(secureStorageProvider)),
);

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.read(apiClientProvider)),
);

final usersNotifierProvider = StateNotifierProvider<UsersNotifier, UsersState>(
  (ref) => UsersNotifier(ref.read(usersRepositoryProvider)),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.read(apiClientProvider)),
);

final statsNotifierProvider = StateNotifierProvider<StatsNotifier, StatsState>(
  (ref) => StatsNotifier(ref.read(statsRepositoryProvider)),
);
