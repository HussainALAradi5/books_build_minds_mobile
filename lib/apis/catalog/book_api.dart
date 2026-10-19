import '../../interfaces/network/api_transport.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/shared/pagination_filter.dart';

class BookApi {
  const BookApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> list(Map<String, String> query) =>
      client.get('/', query: query);

  Future<Map<String, dynamic>> detail(String slug) =>
      client.get(ApiPaths.book(slug));

  Future<Map<String, dynamic>> publishers() => client.get(
    '/publishers',
    query: {...const PaginationFilter(perPage: 50).toQuery(), 'q': ''},
  );
}
