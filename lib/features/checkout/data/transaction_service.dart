import '../../../core/models/page_result.dart';
import '../../../core/network/api_client.dart';
import '../../loans/domain/loan_quote.dart';
import '../domain/library_transaction.dart';

class TransactionService {
  const TransactionService(this._api);

  final ApiClient _api;

  Future<LibraryTransaction> checkout(
    String slug,
    String kind,
    LoanQuote quote,
    String requestKey,
  ) async => LibraryTransaction.fromJson(
    await _api.post(
      '/transactions/checkout',
      body: {
        'book_slug': slug,
        'kind': kind,
        'request_key': requestKey,
        'accepted_terms': true,
        'policy_version': quote.policyVersion,
        'expected_amount_minor': kind == 'purchase'
            ? quote.purchaseAmountMinor
            : quote.rentalAmountMinor,
      },
    ),
  );

  Future<PageResult<LibraryTransaction>> list({int page = 1}) async =>
      PageResult.fromJson(
        await _api.get(
          '/transactions',
          query: {'page': '$page', 'per_page': '10'},
          authenticated: true,
        ),
        LibraryTransaction.fromJson,
      );

  Future<LibraryTransaction> sync(String id) async =>
      LibraryTransaction.fromJson(
        await _api.post('/transactions/${Uri.encodeComponent(id)}/sync'),
      );
}
