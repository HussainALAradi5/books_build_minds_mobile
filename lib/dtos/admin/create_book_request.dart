import '../../enums/catalog/book_condition.dart';

class CreateBookRequest {
  const CreateBookRequest({
    required this.title,
    required this.description,
    required this.isbn,
    required this.author,
    required this.publisher,
    required this.publishedAt,
    required this.price,
    required this.copiesTotal,
    required this.condition,
  });

  final String title;
  final String description;
  final String isbn;
  final String author;
  final String publisher;
  final String publishedAt;
  final double price;
  final int copiesTotal;
  final BookCondition condition;

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'description': description.trim(),
    'isbn': isbn.trim(),
    'author': author.trim(),
    'publisher': publisher.trim(),
    'published_at': publishedAt,
    'price': price,
    'copies_total': copiesTotal,
    'condition': condition.wireValue,
  };
}
