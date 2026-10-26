import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/admin/admin_api.dart';
import '../../models/catalog/book.dart';
import '../../models/admin/access_record.dart';
import '../../dtos/admin/create_book_request.dart';
import '../../dtos/admin/catalog_profile_request.dart';
import '../../models/catalog/country.dart';
import '../../interfaces/network/upload_file.dart';
import '../../interfaces/network/downloaded_file.dart';
import '../../dtos/admin/permission_input.dart';
import '../../dtos/admin/role_input.dart';
import '../../dtos/admin/group_input.dart';
import '../../dtos/admin/user_access_input.dart';
import '../../filters/catalog/book_filter.dart';
import '../../filters/catalog/catalog_search_filter.dart';
import '../../models/catalog/catalog_person.dart';
import '../../models/catalog/category.dart';

class AdminService {
  AdminService(ApiTransport client) : _api = AdminApi(client);

  final AdminApi _api;

  Future<PageResult<Book>> inventory(BookFilter filter) async =>
      PageResult.fromJson(await _api.inventory(filter), Book.fromJson);

  Future<void> updatePrice(String slug, double price) async {
    await _api.updatePrice(slug, price);
  }

  Future<PageResult<AccessRecord>> access(String resource, int page) async =>
      PageResult.fromJson(
        await _api.access(resource, page),
        AccessRecord.fromJson,
      );

  Future<List<AccessRecord>> allAccess(String resource) async {
    final items = <AccessRecord>[];
    for (var page = 1; ; page++) {
      final result = await access(resource, page);
      items.addAll(result.items);
      if (!result.hasNext) return items;
    }
  }

  Future<int> createBook(CreateBookRequest input) async {
    final result = await _api.createBook(input);
    return (result['book'] as Map<String, dynamic>)['book_id'] as int;
  }

  Future<void> createProfile(String kind, CatalogProfileRequest input) async {
    await _api.createProfile(kind, input);
  }

  Future<PageResult<CatalogPerson>> catalogProfiles(
    String kind,
    CatalogSearchFilter filter,
  ) async => PageResult.fromJson(
    await _api.catalogProfiles(kind, filter),
    CatalogPerson.fromJson,
  );

  Future<PageResult<Category>> categories(CatalogSearchFilter filter) async =>
      PageResult.fromJson(await _api.categories(filter), Category.fromJson);

  Future<void> createCategory(String name) async {
    await _api.createCategory(name.trim());
  }

  Future<PageResult<Country>> countries([int page = 1]) async =>
      PageResult.fromJson(await _api.countries(page), Country.fromJson);

  Future<List<Country>> allCountries() async {
    final items = <Country>[];
    for (var page = 1; ; page++) {
      final result = await countries(page);
      items.addAll(result.items);
      if (!result.hasNext) return items;
    }
  }

  Future<void> syncCountries() async {
    await _api.syncCountries();
  }

  Future<int> importBooks(UploadFile file) async =>
      (await _api.importBooks(file))['count'] as int;

  Future<DownloadedFile> exportBooks(String format, List<int> ids) =>
      _api.exportBooks(format, ids);

  Future<void> bulkBooks(List<int> ids, String action) async {
    await _api.bulkBooks(ids, action);
  }

  Future<void> deleteBook(String slug) async {
    await _api.deleteBook(slug);
  }

  Future<void> savePermission(PermissionInput input, String? key) async {
    await _api.savePermission(input, key);
  }

  Future<void> saveRole(RoleInput input, String? key) async {
    await _api.saveRole(input, key);
  }

  Future<void> saveGroup(GroupInput input, int? id) async {
    await _api.saveGroup(input, id);
  }

  Future<void> saveUser(int id, UserAccessInput input) async {
    await _api.saveUser(id, input);
  }

  Future<void> deleteAccess(String resource, String id) async {
    await _api.deleteAccess(resource, id);
  }
}
