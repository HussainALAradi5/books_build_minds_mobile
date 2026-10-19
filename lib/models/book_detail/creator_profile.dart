class CreatorProfile {
  const CreatorProfile({
    required this.name,
    required this.description,
    required this.country,
    required this.works,
  });

  final String name;
  final String description;
  final String country;
  final List<String> works;

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    final country = json['country'] as Map<String, dynamic>?;
    return CreatorProfile(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      country: country?['name'] as String? ?? 'Not listed',
      works: (json['works'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((work) => work['title'] as String? ?? '')
          .where((title) => title.isNotEmpty)
          .toList(),
    );
  }
}
