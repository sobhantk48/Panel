class NetworkInfo {
  final String ip;
  final String colo;
  final String loc;

  NetworkInfo({required this.ip, required this.colo, required this.loc});

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      ip: json['ip']?.toString() ?? 'Unknown',
      colo: json['colo']?.toString() ?? 'Unknown',
      loc: json['loc']?.toString() ?? 'Unknown',
    );
  }
}

class ProfileInfo {
  final String name;
  final String id;
  final String sync;

  ProfileInfo({required this.name, required this.id, required this.sync});

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      name: json['name']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      sync: json['sync']?.toString() ?? '',
    );
  }
}

class AuthResponse {
  final bool success;
  final Map<String, dynamic> config;
  final String? deviceId;
  final NetworkInfo network;
  final Map<String, dynamic> usage;
  final Map<String, dynamic> sysUsage;
  final String version;
  final List<ProfileInfo> profiles;

  AuthResponse({
    required this.success,
    required this.config,
    required this.deviceId,
    required this.network,
    required this.usage,
    required this.sysUsage,
    required this.version,
    required this.profiles,
  });

  /// چون /api/auth هیچ role/permissions برنمی‌گردونه،
  /// این‌طوری تشخیص میدیم کاربر masterKey زده یا panelApiKey:
  /// اگه masterKey باشه، config.masterKey مقدار واقعی رو داره.
  /// اگه panelApiKey باشه، این فیلد "[PROTECTED]" میشه.
  bool get isMasterKey => config['masterKey'] != '[PROTECTED]';

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] == true,
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      deviceId: json['deviceId']?.toString(),
      network: NetworkInfo.fromJson(
        Map<String, dynamic>.from(json['network'] ?? {}),
      ),
      usage: Map<String, dynamic>.from(json['usage'] ?? {}),
      sysUsage: Map<String, dynamic>.from(json['sysUsage'] ?? {}),
      version: json['version']?.toString() ?? '',
      profiles: (json['profiles'] as List<dynamic>? ?? [])
          .map((e) => ProfileInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
