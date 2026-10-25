import '../../interfaces/network/api_transport.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/shared/pagination_filter.dart';

class TransactionApi {
  const TransactionApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> checkout(Map<String, dynamic> body) =>
      client.post('/transactions/checkout', body: body);

  Future<Map<String, dynamic>> list(int page) => client.get(
    '/transactions',
    query: PaginationFilter(page: page, perPage: 10).toQuery(),
    authenticated: true,
  );

  Future<Map<String, dynamic>> sync(String id) =>
      client.post('${ApiPaths.transaction(id)}/sync');

  Future<Map<String, dynamic>> detail(String id) =>
      client.get(ApiPaths.transaction(id), authenticated: true);

  Future<Map<String, dynamic>> cancel(String id) =>
      client.post('${ApiPaths.transaction(id)}/cancel');
}
