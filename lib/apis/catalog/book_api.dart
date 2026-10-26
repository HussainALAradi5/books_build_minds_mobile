import '../../interfaces/network/api_transport.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/catalog/catalog_search_filter.dart';

class BookApi {
  const BookApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> list(Map<String, String> query) =>
      client.get('/', query: query);

  Future<Map<String, dynamic>> detail(String slug) =>
      client.get(ApiPaths.book(slug));

  Future<Map<String, dynamic>> categories(CatalogSearchFilter filter) =>
      client.get('/categories', query: filter.toQuery());

  Future<Map<String, dynamic>> catalogProfiles(
    String kind,
    CatalogSearchFilter filter,
  ) => client.get('/$kind', query: filter.toQuery());

  Future<Map<String, dynamic>> topCategories(int page, String sort) =>
      client.get(
        '/categories/top',
        query: {'page': '$page', 'per_page': '6', 'sort': sort},
      );
}
