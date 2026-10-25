class GroupInput {
  const GroupInput({
    required this.name,
    required this.description,
    required this.roleKeys,
  });
  final String name;
  final String description;
  final List<String> roleKeys;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'description': description.trim(),
    'role_keys': roleKeys,
  };
}
