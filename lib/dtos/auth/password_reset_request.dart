class PasswordResetRequest {
  const PasswordResetRequest({required this.identifier});

  final String identifier;

  Map<String, dynamic> toJson() => {'identifier': identifier.trim()};
}
