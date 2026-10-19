import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/admin/admin_api.dart';
import '../../models/catalog/book.dart';
import '../../models/admin/access_record.dart';

class AdminService {
  AdminService(ApiTransport client) : _api = AdminApi(client);

  final AdminApi _api;

  Future<PageResult<Book>> inventory(int page) async =>
      PageResult.fromJson(await _api.inventory(page), Book.fromJson);

  Future<void> updatePrice(String slug, double price) async {
    await _api.updatePrice(slug, price);
  }

  Future<PageResult<AccessRecord>> access(String resource, int page) async =>
      PageResult.fromJson(
        await _api.access(resource, page),
        AccessRecord.fromJson,
      );
}
