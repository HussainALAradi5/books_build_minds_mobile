class LoanQuote {
  const LoanQuote({
    required this.availableCopies,
    required this.borrowDays,
    required this.rentalDays,
    required this.purchaseAmountMinor,
    required this.rentalAmountMinor,
    required this.policyVersion,
    required this.terms,
    required this.currencyScale,
  });

  final int availableCopies;
  final int borrowDays;
  final int rentalDays;
  final int purchaseAmountMinor;
  final int rentalAmountMinor;
  final int currencyScale;
  final String policyVersion;
  final List<String> terms;

  factory LoanQuote.fromJson(Map<String, dynamic> json) => LoanQuote(
    availableCopies: json['available_copies'] as int? ?? 0,
    borrowDays: json['borrow_days'] as int? ?? 14,
    rentalDays: json['rental_days'] as int? ?? 7,
    purchaseAmountMinor: json['purchase_amount_minor'] as int? ?? 0,
    rentalAmountMinor: json['rental_amount_minor'] as int? ?? 0,
    currencyScale: json['currency_scale'] as int? ?? 1000,
    policyVersion: json['policy_version'] as String? ?? '',
    terms: (json['terms'] as List<dynamic>? ?? []).whereType<String>().toList(),
  );
}
