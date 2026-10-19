import '../../interfaces/network/api_transport.dart';
import '../../shared/network/api_paths.dart';

class BookDetailApi {
  const BookDetailApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> get(String slug) =>
      client.get(ApiPaths.book(slug));

  Uri printUrl(String slug) =>
      client.endpointUri('${ApiPaths.book(slug)}/print');
}
