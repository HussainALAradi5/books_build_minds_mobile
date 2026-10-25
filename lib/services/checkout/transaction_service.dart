import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/checkout/transaction_api.dart';
import '../../dtos/checkout/checkout_request.dart';
import '../../models/loans/loan_quote.dart';
import '../../models/checkout/library_transaction.dart';

class TransactionService {
  TransactionService(ApiTransport client) : _api = TransactionApi(client);

  final TransactionApi _api;

  Future<LibraryTransaction> checkout(
    String slug,
    String kind,
    LoanQuote quote,
    String requestKey,
  ) async => LibraryTransaction.fromJson(
    await _api.checkout(
      CheckoutRequest(
        slug: slug,
        kind: kind,
        quote: quote,
        requestKey: requestKey,
      ).toJson(),
    ),
  );

  Future<PageResult<LibraryTransaction>> list({int page = 1}) async =>
      PageResult.fromJson(await _api.list(page), LibraryTransaction.fromJson);

  Future<LibraryTransaction> sync(String id) async =>
      LibraryTransaction.fromJson(await _api.sync(id));

  Future<LibraryTransaction> detail(String id) async =>
      LibraryTransaction.fromJson(await _api.detail(id));

  Future<LibraryTransaction> cancel(String id) async =>
      LibraryTransaction.fromJson(await _api.cancel(id));
}
