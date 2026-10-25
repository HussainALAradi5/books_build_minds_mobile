class CatalogProfileRequest {
  const CatalogProfileRequest({
    required this.name,
    required this.description,
    this.countryCode,
  });
  final String name;
  final String description;
  final String? countryCode;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'description': description.trim(),
    'country_code': countryCode,
  };
}
