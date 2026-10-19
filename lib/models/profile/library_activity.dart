class LibraryActivity {
  const LibraryActivity({
    required this.bookTitle,
    required this.action,
    required this.occurredAt,
  });

  final String bookTitle;
  final String action;
  final String occurredAt;

  factory LibraryActivity.fromJson(Map<String, dynamic> json) =>
      LibraryActivity(
        bookTitle: json['book_title'] as String? ?? '',
        action: json['action_type'] as String? ?? '',
        occurredAt: json['occurred_at'] as String? ?? '',
      );
}
