class RoleInput {
  const RoleInput({
    required this.key,
    required this.name,
    required this.description,
    required this.permissionKeys,
  });
  final String key;
  final String name;
  final String description;
  final List<String> permissionKeys;

  Map<String, dynamic> toJson() => {
    'key': key.trim(),
    'name': name.trim(),
    'description': description.trim(),
    'permission_keys': permissionKeys,
  };
}
