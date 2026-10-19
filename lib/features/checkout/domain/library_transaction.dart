class LibraryTransaction {
  const LibraryTransaction({
    required this.id,
    required this.bookTitle,
    required this.kind,
    required this.status,
    required this.amountMinor,
    required this.currencyScale,
    this.checkoutUrl,
    this.failureReason,
  });

  final String id;
  final String bookTitle;
  final String kind;
  final String status;
  final int amountMinor;
  final int currencyScale;
  final String? checkoutUrl;
  final String? failureReason;

  factory LibraryTransaction.fromJson(Map<String, dynamic> json) =>
      LibraryTransaction(
        id: json['transaction_id'] as String? ?? '',
        bookTitle: json['book_title'] as String? ?? '',
        kind: json['kind'] as String? ?? '',
        status: json['status'] as String? ?? '',
        amountMinor: json['amount_minor'] as int? ?? 0,
        currencyScale: json['currency_scale'] as int? ?? 1000,
        checkoutUrl: json['checkout_url'] as String?,
        failureReason: json['failure_reason'] as String?,
      );
}
