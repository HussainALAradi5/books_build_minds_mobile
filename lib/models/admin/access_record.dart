class AccessRecord {
  const AccessRecord({
    required this.name,
    required this.detail,
    required this.isSystem,
    this.key,
    this.id,
    this.role,
    this.permissionKeys = const [],
    this.roleKeys = const [],
    this.accessRoleKeys = const [],
    this.groupIds = const [],
  });

  final String name;
  final String detail;
  final bool isSystem;
  final String? key;
  final int? id;
  final String? role;
  final List<String> permissionKeys;
  final List<String> roleKeys;
  final List<String> accessRoleKeys;
  final List<int> groupIds;

  factory AccessRecord.fromJson(Map<String, dynamic> json) => AccessRecord(
    name:
        (json['name'] ?? json['label'] ?? json['user_name'] ?? json['key'])
            as String? ??
        'Unnamed',
    detail:
        (json['description'] ?? json['email'] ?? json['key']) as String? ?? '',
    isSystem: json['is_system'] as bool? ?? false,
    key: json['key'] as String?,
    id: json['group_id'] as int? ?? json['user_id'] as int?,
    role: json['role'] as String?,
    permissionKeys: (json['permission_keys'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList(),
    roleKeys: (json['role_keys'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList(),
    accessRoleKeys: (json['access_role_keys'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList(),
    groupIds: (json['group_ids'] as List<dynamic>? ?? [])
        .whereType<int>()
        .toList(),
  );
}
