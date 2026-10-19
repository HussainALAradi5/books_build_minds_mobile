class PasswordResetConfirmation {
  const PasswordResetConfirmation({
    required this.identifier,
    required this.code,
    required this.newPassword,
  });

  final String identifier;
  final String code;
  final String newPassword;

  Map<String, dynamic> toJson() => {
    'identifier': identifier.trim(),
    'code': code.trim(),
    'new_password': newPassword,
  };
}
