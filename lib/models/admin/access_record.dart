class AccessRecord {
  const AccessRecord({
    required this.name,
    required this.detail,
    required this.isSystem,
  });

  final String name;
  final String detail;
  final bool isSystem;

  factory AccessRecord.fromJson(Map<String, dynamic> json) => AccessRecord(
    name:
        (json['name'] ?? json['label'] ?? json['user_name'] ?? json['key'])
            as String? ??
        'Unnamed',
    detail:
        (json['description'] ?? json['email'] ?? json['key']) as String? ?? '',
    isSystem: json['is_system'] as bool? ?? false,
  );
}
