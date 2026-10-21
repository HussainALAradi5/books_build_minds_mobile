String normalizeMobileNumber(String value) =>
    value.replaceAll(RegExp(r'[\s()-]'), '');

String? optionalMobileError(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = normalizeMobileNumber(value);
  return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized)
      ? null
      : 'Use international format, for example +97312345678';
}
