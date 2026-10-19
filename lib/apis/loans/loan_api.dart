import '../../interfaces/network/api_transport.dart';
import '../../dtos/loans/borrow_request.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/loans/loan_filter.dart';

class LoanApi {
  const LoanApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> quote(String slug) =>
      client.get('${ApiPaths.book(slug)}/quote', authenticated: true);

  Future<Map<String, dynamic>> current(String slug) =>
      client.get('${ApiPaths.book(slug)}/loan', authenticated: true);

  Future<Map<String, dynamic>> borrow(String slug, String policyVersion) =>
      client.post(
        '${ApiPaths.book(slug)}/borrow',
        body: BorrowRequest(policyVersion: policyVersion).toJson(),
      );

  Future<Map<String, dynamic>> returnBook(String slug) =>
      client.post('${ApiPaths.book(slug)}/return');

  Future<Map<String, dynamic>> list(int userId, LoanFilter filter) =>
      client.get(
        '${ApiPaths.profile(userId)}/loans',
        query: filter.toQuery(),
        authenticated: true,
      );
}
