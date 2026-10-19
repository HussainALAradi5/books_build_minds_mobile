class Loan {
  const Loan({
    required this.id,
    required this.bookTitle,
    required this.bookSlug,
    required this.status,
    required this.kind,
    required this.dueAt,
  });

  final int id;
  final String bookTitle;
  final String bookSlug;
  final String status;
  final String kind;
  final String dueAt;

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['loan_id'] as int? ?? 0,
    bookTitle: json['book_title'] as String? ?? '',
    bookSlug: json['book_slug'] as String? ?? '',
    status: json['status'] as String? ?? '',
    kind: json['loan_kind'] as String? ?? '',
    dueAt: json['due_at'] as String? ?? '',
  );
}
