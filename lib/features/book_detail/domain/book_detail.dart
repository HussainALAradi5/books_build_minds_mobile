import '../../catalog/domain/book.dart';
import 'creator_profile.dart';

class BookDetail {
  const BookDetail({required this.book, this.author, this.publisher});

  final Book book;
  final CreatorProfile? author;
  final CreatorProfile? publisher;

  factory BookDetail.fromJson(Map<String, dynamic> json) => BookDetail(
    book: Book.fromJson(json),
    author: json['author_details'] is Map<String, dynamic>
        ? CreatorProfile.fromJson(
            json['author_details'] as Map<String, dynamic>,
          )
        : null,
    publisher: json['publisher_details'] is Map<String, dynamic>
        ? CreatorProfile.fromJson(
            json['publisher_details'] as Map<String, dynamic>,
          )
        : null,
  );
}
