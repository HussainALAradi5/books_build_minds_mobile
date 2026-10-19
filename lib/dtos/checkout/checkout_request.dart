import '../../models/loans/loan_quote.dart';

class CheckoutRequest {
  const CheckoutRequest({
    required this.slug,
    required this.kind,
    required this.quote,
    required this.requestKey,
  });

  final String slug;
  final String kind;
  final LoanQuote quote;
  final String requestKey;

  Map<String, dynamic> toJson() => {
    'book_slug': slug,
    'kind': kind,
    'request_key': requestKey,
    'accepted_terms': true,
    'policy_version': quote.policyVersion,
    'expected_amount_minor': kind == 'purchase'
        ? quote.purchaseAmountMinor
        : quote.rentalAmountMinor,
  };
}
