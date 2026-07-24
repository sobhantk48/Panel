class UserStats {
  final int total;
  final int active;
  final int paused;
  final int expired;
  final int autoDisabled;

  UserStats({
    required this.total,
    required this.active,
    required this.paused,
    required this.expired,
    required this.autoDisabled,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: (json['total'] ?? 0) as int,
      active: (json['active'] ?? 0) as int,
      paused: (json['paused'] ?? 0) as int,
      expired: (json['expired'] ?? 0) as int,
      autoDisabled: (json['autoDisabled'] ?? 0) as int,
    );
  }
}

class TrafficStats {
  final int totalRequests;
  final double totalGB;
  final int dailyRequests;
  final double dailyGB;

  TrafficStats({
    required this.totalRequests,
    required this.totalGB,
    required this.dailyRequests,
    required this.dailyGB,
  });

  factory TrafficStats.fromJson(Map<String, dynamic> json) {
    return TrafficStats(
      totalRequests: (json['totalRequests'] ?? 0) as int,
      totalGB: double.tryParse(json['totalGB']?.toString() ?? '0') ?? 0,
      dailyRequests: (json['dailyRequests'] ?? 0) as int,
      dailyGB: double.tryParse(json['dailyGB']?.toString() ?? '0') ?? 0,
    );
  }
}

class SystemStats {
  final int uptimeSeconds;
  final int activeConnections;
  final String version;
  final bool isPaused;

  SystemStats({
    required this.uptimeSeconds,
    required this.activeConnections,
    required this.version,
    required this.isPaused,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      uptimeSeconds: (json['uptimeSeconds'] ?? 0) as int,
      activeConnections: (json['activeConnections'] ?? 0) as int,
      version: json['version']?.toString() ?? '',
      isPaused: json['isPaused'] == true,
    );
  }

  String get uptimeFormatted {
    final d = Duration(seconds: uptimeSeconds);
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) return '$days روز و $hours ساعت';
    if (hours > 0) return '$hours ساعت و $minutes دقیقه';
    return '$minutes دقیقه';
  }
}

class DashboardStats {
  final UserStats users;
  final TrafficStats traffic;
  final SystemStats system;

  DashboardStats({
    required this.users,
    required this.traffic,
    required this.system,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      users: UserStats.fromJson(json['users'] ?? {}),
      traffic: TrafficStats.fromJson(json['traffic'] ?? {}),
      system: SystemStats.fromJson(json['system'] ?? {}),
    );
  }
}
