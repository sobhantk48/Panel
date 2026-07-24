class StatsModel {
  final UsersStats users;
  final TrafficStats traffic;
  final Map<String, UsageEntry> usage;
  final SystemStats system;

  StatsModel({
    required this.users,
    required this.traffic,
    required this.usage,
    required this.system,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    final usageJson = (json['usage'] as Map<String, dynamic>?) ?? {};
    return StatsModel(
      users: UsersStats.fromJson(json['users'] ?? {}),
      traffic: TrafficStats.fromJson(json['traffic'] ?? {}),
      usage: usageJson.map(
        (key, value) => MapEntry(
          key,
          UsageEntry.fromJson(value as Map<String, dynamic>),
        ),
      ),
      system: SystemStats.fromJson(json['system'] ?? {}),
    );
  }
}

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

  // نکته: totalGB و dailyGB توی جیسون worker به صورت String هستن
  // چون خروجی toFixed(2) تو جاوااسکریپت رشته‌ست، نه عدد.
  factory TrafficStats.fromJson(Map<String, dynamic> json) {
    return TrafficStats(
      totalRequests: (json['totalRequests'] ?? 0) as int,
      totalGB: double.tryParse(json['totalGB']?.toString() ?? '0') ?? 0.0,
      dailyRequests: (json['dailyRequests'] ?? 0) as int,
      dailyGB: double.tryParse(json['dailyGB']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// هر entry داخل usage از uuidUsage میاد + فیلد connects که هندلر اضافه میکنه.
// چون ساختار دقیق فیلدهای uuidUsage در ورودی مشخص و ثابت مستند نشده،
// این مدل rawJson رو هم نگه میداره تا هیچ دیتایی از دست نره.
class UsageEntry {
  final int connects;
  final Map<String, dynamic> raw;

  UsageEntry({
    required this.connects,
    required this.raw,
  });

  factory UsageEntry.fromJson(Map<String, dynamic> json) {
    return UsageEntry(
      connects: (json['connects'] ?? 0) as int,
      raw: json,
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
      version: (json['version'] ?? '') as String,
      isPaused: (json['isPaused'] ?? false) as bool,
    );
  }
}
