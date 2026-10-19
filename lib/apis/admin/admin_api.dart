import '../../interfaces/network/api_transport.dart';
import '../../dtos/admin/update_price_request.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/shared/pagination_filter.dart';

class AdminApi {
  const AdminApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> inventory(int page) => client.get(
    '/book/manage',
    query: PaginationFilter(page: page).toQuery(),
    authenticated: true,
  );

  Future<void> updatePrice(String slug, double price) async {
    await client.patch(
      '${ApiPaths.book(slug)}/price',
      body: UpdatePriceRequest(price).toJson(),
    );
  }

  Future<Map<String, dynamic>> access(String resource, int page) => client.get(
    '/access/$resource',
    query: PaginationFilter(page: page).toQuery(),
    authenticated: true,
  );
}
