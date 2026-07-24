class UsersStats {
  final int total;
  final int active;
  final int paused;
  final int expired;
  final int autoDisabled;

  UsersStats({
    required this.total,
    required this.active,
    required this.paused,
    required this.expired,
    required this.autoDisabled,
  });

  factory UsersStats.fromJson(Map<String, dynamic> json) {
    return UsersStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      paused: (json['paused'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      autoDisabled: (json['autoDisabled'] as num?)?.toInt() ?? 0,
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
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
      totalGB: double.tryParse(json['totalGB']?.toString() ?? '') ?? 0.0,
      dailyRequests: (json['dailyRequests'] as num?)?.toInt() ?? 0,
      dailyGB: double.tryParse(json['dailyGB']?.toString() ?? '') ?? 0.0,
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
      uptimeSeconds: (json['uptimeSeconds'] as num?)?.toInt() ?? 0,
      activeConnections: (json['activeConnections'] as num?)?.toInt() ?? 0,
      version: json['version']?.toString() ?? '',
      isPaused: json['isPaused'] as bool? ?? false,
    );
  }

  String get uptimeFormatted {
    final days = uptimeSeconds ~/ 86400;
    final hours = (uptimeSeconds % 86400) ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;
    if (days > 0) return '$days روز $hours ساعت';
    if (hours > 0) return '$hours ساعت $minutes دقیقه';
    return '$minutes دقیقه';
  }
}

class UsageEntry {
  final String key;
  final int connects;
  final Map<String, dynamic> raw;

  UsageEntry({
    required this.key,
    required this.connects,
    required this.raw,
  });

  factory UsageEntry.fromJson(String key, Map<String, dynamic> json) {
    return UsageEntry(
      key: key,
      connects: (json['connects'] as num?)?.toInt() ?? 0,
      raw: json,
    );
  }
}

class StatsModel {
  final UsersStats users;
  final TrafficStats traffic;
  final List<UsageEntry> usage;
  final SystemStats system;

  StatsModel({
    required this.users,
    required this.traffic,
    required this.usage,
    required this.system,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    final usageMap = (json['usage'] as Map<String, dynamic>?) ?? {};
    final usageList = usageMap.entries
        .map((e) => UsageEntry.fromJson(e.key, e.value as Map<String, dynamic>))
        .toList();

    return StatsModel(
      users: UsersStats.fromJson(json['users'] as Map<String, dynamic>? ?? {}),
      traffic: TrafficStats.fromJson(json['traffic'] as Map<String, dynamic>? ?? {}),
      usage: usageList,
      system: SystemStats.fromJson(json['system'] as Map<String, dynamic>? ?? {}),
    );
  }
}
