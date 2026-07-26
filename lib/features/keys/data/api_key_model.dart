class ApiKeyEntry {
  final String id;
  final String name;
  final String keyPreview;
  final DateTime? createdAt;
  final DateTime? lastUsed;

  /// فقط در پاسخ ساخت کلید جدید پر می‌شود (سرور یک بار کلید کامل را برمی‌گرداند).
  final String? fullKey;

  const ApiKeyEntry({
    required this.id,
    required this.name,
    required this.keyPreview,
    this.createdAt,
    this.lastUsed,
    this.fullKey,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final asInt = int.tryParse(v);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      return DateTime.tryParse(v);
    }
    return null;
  }

  factory ApiKeyEntry.fromJson(Map<String, dynamic> json) {
    final key = json['key'] as String?;
    var preview = json['keyPreview'] as String?;
    if (preview == null && key != null && key.length > 12) {
      preview = '${key.substring(0, 8)}...${key.substring(key.length - 4)}';
    }
    return ApiKeyEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      keyPreview: preview ?? key ?? '',
      createdAt: _parseDate(json['createdAt']),
      lastUsed: _parseDate(json['lastUsed']),
      fullKey: key,
    );
  }
}
