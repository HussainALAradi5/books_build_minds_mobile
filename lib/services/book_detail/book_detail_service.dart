import '../../interfaces/network/api_transport.dart';
import '../../apis/book_detail/book_detail_api.dart';
import '../../models/book_detail/book_detail.dart';
import '../../models/book_detail/book_codes.dart';

class BookDetailService {
  BookDetailService(ApiTransport client) : _api = BookDetailApi(client);

  final BookDetailApi _api;

  Future<BookDetail> get(String slug) async =>
      BookDetail.fromJson(await _api.get(slug));

  Uri printUrl(String slug) => _api.printUrl(slug);

  Future<BookCodes> codes(String slug) async =>
      BookCodes.fromJson(await _api.codes(slug));
}
