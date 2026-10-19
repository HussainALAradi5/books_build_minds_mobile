import '../../../core/models/page_result.dart';
import '../../../core/network/api_client.dart';
import '../domain/book.dart';
import '../domain/book_filter.dart';

class BookService {
  const BookService(this._api);

  final ApiClient _api;

  Future<PageResult<Book>> list(BookFilter filter) async => PageResult.fromJson(
    await _api.get('/', query: filter.toQuery()),
    Book.fromJson,
  );

  Future<Book> detail(String slug) async =>
      Book.fromJson(await _api.get('/book/${Uri.encodeComponent(slug)}'));

  Future<List<String>> publishers() async {
    final page = await _api.get(
      '/publishers',
      query: {'page': '1', 'per_page': '50', 'q': ''},
    );
    return (page['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
