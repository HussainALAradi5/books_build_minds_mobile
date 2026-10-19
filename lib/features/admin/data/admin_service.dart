import '../../../core/models/page_result.dart';
import '../../../core/network/api_client.dart';
import '../../catalog/domain/book.dart';
import '../domain/access_record.dart';

class AdminService {
  const AdminService(this._api);

  final ApiClient _api;

  Future<PageResult<Book>> inventory(int page) async => PageResult.fromJson(
    await _api.get(
      '/book/manage',
      query: {'page': '$page'},
      authenticated: true,
    ),
    Book.fromJson,
  );

  Future<void> updatePrice(String slug, double price) async {
    await _api.patch(
      '/book/${Uri.encodeComponent(slug)}/price',
      body: {'price': price},
    );
  }

  Future<PageResult<AccessRecord>> access(String resource, int page) async =>
      PageResult.fromJson(
        await _api.get(
          '/access/$resource',
          query: {'page': '$page'},
          authenticated: true,
        ),
        AccessRecord.fromJson,
      );
}
