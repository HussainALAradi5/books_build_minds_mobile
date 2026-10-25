class UserAccessInput {
  const UserAccessInput({
    required this.role,
    required this.accessRoleKeys,
    required this.groupIds,
  });
  final String role;
  final List<String> accessRoleKeys;
  final List<int> groupIds;

  Map<String, dynamic> toJson() => {
    'role': role,
    'access_role_keys': accessRoleKeys,
    'group_ids': groupIds,
  };
}
