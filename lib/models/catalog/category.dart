class Category {
  const Category({required this.id, required this.name, required this.slug});
  final int id;
  final String name;
  final String slug;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['category_id'] as int,
    name: json['name'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
  );
}
