class CatalogPerson {
  const CatalogPerson({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.country,
  });

  final int id;
  final String name;
  final String description;
  final String address;
  final String? country;

  factory CatalogPerson.fromJson(Map<String, dynamic> json) => CatalogPerson(
    id: (json['author_id'] ?? json['publisher_id']) as int,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    address: json['address'] as String? ?? '',
    country: (json['country'] as Map<String, dynamic>?)?['name'] as String?,
  );
}
