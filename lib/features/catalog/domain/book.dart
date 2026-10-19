import 'book_condition.dart';

class Book {
  const Book({
    required this.bookId,
    required this.slug,
    required this.title,
    required this.author,
    required this.publisher,
    required this.price,
    required this.copiesTotal,
    required this.availableCopies,
    required this.averageRating,
    this.condition,
    this.imagePath,
    this.description = '',
    this.isbn = '',
    this.publishedAt = '',
  });

  final int bookId;
  final String slug;
  final String title;
  final String author;
  final String publisher;
  final double price;
  final int copiesTotal;
  final int availableCopies;
  final double averageRating;
  final BookCondition? condition;
  final String? imagePath;
  final String description;
  final String isbn;
  final String publishedAt;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    bookId: json['book_id'] as int? ?? 0,
    slug: json['slug'] as String? ?? '',
    title: json['title'] as String? ?? '',
    author: json['author'] as String? ?? '',
    publisher: json['publisher'] as String? ?? '',
    price: (json['price'] as num? ?? 0).toDouble(),
    copiesTotal: json['copies_total'] as int? ?? 0,
    availableCopies: json['available_copies'] as int? ?? 0,
    averageRating: (json['average_rating'] as num? ?? 0).toDouble(),
    condition: BookConditionView.fromWire(json['condition'] as String?),
    imagePath: json['book_image'] as String?,
    description: json['description'] as String? ?? '',
    isbn: json['isbn'] as String? ?? '',
    publishedAt: json['published_at'] as String? ?? '',
  );
}
