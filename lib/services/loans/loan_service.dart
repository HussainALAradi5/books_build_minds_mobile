import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/loans/loan_api.dart';
import '../../models/loans/loan.dart';
import '../../models/loans/loan_quote.dart';
import '../../filters/loans/loan_filter.dart';
import '../../enums/loans/loan_status.dart';

class LoanService {
  LoanService(ApiTransport client) : _api = LoanApi(client);

  final LoanApi _api;

  Future<LoanQuote> quote(String slug) async =>
      LoanQuote.fromJson(await _api.quote(slug));

  Future<Loan?> current(String slug) async {
    final data = await _api.current(slug);
    return data['loan'] is Map<String, dynamic>
        ? Loan.fromJson(data['loan'] as Map<String, dynamic>)
        : null;
  }

  Future<Loan> borrow(String slug, LoanQuote quote) async {
    final data = await _api.borrow(slug, quote.policyVersion);
    return Loan.fromJson(data['loan'] as Map<String, dynamic>);
  }

  Future<Loan> returnBook(String slug) async {
    final data = await _api.returnBook(slug);
    return Loan.fromJson(data['loan'] as Map<String, dynamic>);
  }

  Future<PageResult<Loan>> list(
    int userId, {
    int page = 1,
    LoanStatus? status,
  }) async => PageResult.fromJson(
    await _api.list(userId, LoanFilter(page: page, status: status)),
    Loan.fromJson,
  );
}
