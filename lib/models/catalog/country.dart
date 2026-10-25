class Country {
  const Country({required this.code, required this.name});
  final String code;
  final String name;

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(code: json['code'] as String, name: json['name'] as String);
}
