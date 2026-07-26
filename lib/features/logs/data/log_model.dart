class LogEntry {
  final String ts;
  final String type;
  final String detail;

  const LogEntry({
    required this.ts,
    required this.type,
    required this.detail,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      ts: (json['ts'] ?? '').toString(),
      type: (json['type'] ?? 'Unknown').toString(),
      detail: (json['detail'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ts': ts,
        'type': type,
        'detail': detail,
      };

  DateTime? get dateTime => DateTime.tryParse(ts)?.toLocal();

  String get formattedDate {
    final d = dateTime;
    if (d == null) return ts;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}/${two(d.month)}/${two(d.day)}  ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}
