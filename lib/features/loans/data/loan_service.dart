import '../../../core/models/page_result.dart';
import '../../../core/network/api_client.dart';
import '../domain/loan.dart';
import '../domain/loan_quote.dart';

class LoanService {
  const LoanService(this._api);

  final ApiClient _api;

  Future<LoanQuote> quote(String slug) async => LoanQuote.fromJson(
    await _api.get(
      '/book/${Uri.encodeComponent(slug)}/quote',
      authenticated: true,
    ),
  );

  Future<Loan?> current(String slug) async {
    final data = await _api.get(
      '/book/${Uri.encodeComponent(slug)}/loan',
      authenticated: true,
    );
    return data['loan'] is Map<String, dynamic>
        ? Loan.fromJson(data['loan'] as Map<String, dynamic>)
        : null;
  }

  Future<Loan> borrow(String slug, LoanQuote quote) async {
    final data = await _api.post(
      '/book/${Uri.encodeComponent(slug)}/borrow',
      body: {'accepted_terms': true, 'policy_version': quote.policyVersion},
    );
    return Loan.fromJson(data['loan'] as Map<String, dynamic>);
  }

  Future<Loan> returnBook(String slug) async {
    final data = await _api.post('/book/${Uri.encodeComponent(slug)}/return');
    return Loan.fromJson(data['loan'] as Map<String, dynamic>);
  }

  Future<PageResult<Loan>> list(
    int userId, {
    int page = 1,
    String status = 'all',
  }) async => PageResult.fromJson(
    await _api.get(
      '/profile/$userId/loans',
      query: {'page': '$page', 'status': status},
      authenticated: true,
    ),
    Loan.fromJson,
  );
}
