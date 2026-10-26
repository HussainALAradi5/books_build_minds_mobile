class CatalogProfileRequest {
  const CatalogProfileRequest({
    required this.name,
    required this.description,
    required this.address,
    this.countryCode,
  });
  final String name;
  final String description;
  final String address;
  final String? countryCode;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'description': description.trim(),
    'address': address.trim(),
    'country_code': countryCode,
  };
}
