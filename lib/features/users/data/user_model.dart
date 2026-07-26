class UserUsage {
  final int total;
  final int limit;
  final int daily;
  final int dailyLimit;

  const UserUsage({
    required this.total,
    required this.limit,
    required this.daily,
    required this.dailyLimit,
  });

  factory UserUsage.fromJson(Map<String, dynamic> j) => UserUsage(
        total: j['total'] ?? 0,
        limit: j['limit'] ?? 0,
        daily: j['daily'] ?? 0,
        dailyLimit: j['dailyLimit'] ?? 0,
      );
}

class NahanUser {
  final String id;
  final String name;
  final int? limitTotalReq;
  final int? limitDailyReq;
  final int? expiryMs;
  final String? notes;
  final int? maxConfigs;
  final String? proxyIp;
  final String? cleanIp;
  final String? userMode;
  final String? userPorts;
  final String? userNodes;
  final String? nat64;
  final String? userPanelUrl;
  final int? connLimit;
  final int createdAt;
  final UserUsage? usage;
  final String status;
  final String? subscriptionUrl;

  const NahanUser({
    required this.id,
    required this.name,
    this.limitTotalReq,
    this.limitDailyReq,
    this.expiryMs,
    this.notes,
    this.maxConfigs,
    this.proxyIp,
    this.cleanIp,
    this.userMode,
    this.userPorts,
    this.userNodes,
    this.nat64,
    this.userPanelUrl,
    this.connLimit,
    required this.createdAt,
    this.usage,
    required this.status,
    this.subscriptionUrl,
  });

  factory NahanUser.fromJson(Map<String, dynamic> j) => NahanUser(
        id: j['id'],
        name: j['name'],
        limitTotalReq: j['limitTotalReq'],
        limitDailyReq: j['limitDailyReq'],
        expiryMs: j['expiryMs'],
        notes: j['notes'],
        maxConfigs: j['maxConfigs'],
        proxyIp: j['proxyIp'],
        cleanIp: j['cleanIp'],
        userMode: j['userMode'],
        userPorts: j['userPorts'],
        userNodes: j['userNodes'],
        nat64: j['nat64'],
        userPanelUrl: j['userPanelUrl'],
        connLimit: j['connLimit'],
        createdAt: j['createdAt'] ?? 0,
        usage: j['usage'] != null ? UserUsage.fromJson(j['usage']) : null,
        status: j['status'] ?? 'active',
        subscriptionUrl: j['subscriptionUrl'],
      );

  double? get trafficLimitGb =>
      limitTotalReq != null ? limitTotalReq! / 6000 : null;

  double? get dailyLimitGb =>
      limitDailyReq != null ? limitDailyReq! / 6000 : null;
}
