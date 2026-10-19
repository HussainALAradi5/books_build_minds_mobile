import '../../interfaces/network/api_transport.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/reviews/review_filter.dart';

class ReviewApi {
  const ReviewApi(this.client);

  final ApiTransport client;

  String path(String slug) => '${ApiPaths.book(slug)}/review';

  Future<Map<String, dynamic>> list(String slug, ReviewFilter filter) =>
      client.get(
        path(slug),
        query: filter.toQuery(),
        authenticated: filter.includeDeleted,
      );

  Future<Map<String, dynamic>> mine(String slug) =>
      client.get('${path(slug)}/mine', authenticated: true);

  Future<void> save(String slug, int? id, Map<String, dynamic> body) async {
    if (id == null) {
      await client.post(path(slug), body: body);
    } else {
      await client.put('${path(slug)}/$id', body: body);
    }
  }

  Future<void> delete(String slug, int id) async {
    await client.delete('${path(slug)}/$id');
  }
}
