class PermissionInput {
  const PermissionInput({
    required this.key,
    required this.label,
    required this.description,
  });
  final String key;
  final String label;
  final String description;

  Map<String, dynamic> toJson() => {
    'key': key.trim(),
    'label': label.trim(),
    'description': description.trim(),
  };
}
