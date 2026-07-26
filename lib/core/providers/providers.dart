import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/users/data/users_repository.dart';
import '../../features/users/application/users_notifier.dart';
import '../../features/users/application/users_state.dart';
import '../../features/dashboard/data/stats_repository.dart';
import '../../features/dashboard/application/stats_notifier.dart';
import '../../features/dashboard/application/stats_state.dart';
import '../../features/logs/data/logs_repository.dart';
import '../../features/logs/application/logs_notifier.dart';
import '../../features/logs/application/logs_state.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => SecureStorageService(),
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

final logsRepositoryProvider = Provider<LogsRepository>(
  (ref) => LogsRepository(ref.read(apiClientProvider)),
);

final logsNotifierProvider = StateNotifierProvider<LogsNotifier, LogsState>(
  (ref) => LogsNotifier(ref.read(logsRepositoryProvider)),
);
