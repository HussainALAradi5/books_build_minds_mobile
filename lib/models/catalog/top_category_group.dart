import 'book.dart';
import 'category.dart';

class TopCategoryGroup {
  const TopCategoryGroup({required this.category, required this.books});
  final Category category;
  final List<Book> books;

  factory TopCategoryGroup.fromJson(Map<String, dynamic> json) =>
      TopCategoryGroup(
        category: Category.fromJson(json['category'] as Map<String, dynamic>),
        books: (json['books'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(Book.fromJson)
            .toList(),
      );
}
