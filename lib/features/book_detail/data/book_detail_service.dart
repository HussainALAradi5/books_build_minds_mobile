import '../../../core/network/api_client.dart';
import '../domain/book_detail.dart';

class BookDetailService {
  const BookDetailService(this._api);

  final ApiClient _api;

  Future<BookDetail> get(String slug) async =>
      BookDetail.fromJson(await _api.get('/book/${Uri.encodeComponent(slug)}'));
}
