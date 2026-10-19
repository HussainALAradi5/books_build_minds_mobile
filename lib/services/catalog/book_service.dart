import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/catalog/book_api.dart';
import '../../models/catalog/book.dart';
import '../../filters/catalog/book_filter.dart';

class BookService {
  BookService(ApiTransport client) : _api = BookApi(client);

  final BookApi _api;

  Future<PageResult<Book>> list(BookFilter filter) async =>
      PageResult.fromJson(await _api.list(filter.toQuery()), Book.fromJson);

  Future<Book> detail(String slug) async =>
      Book.fromJson(await _api.detail(slug));

  Future<List<String>> publishers() async {
    final page = await _api.publishers();
    return (page['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
