import '../../interfaces/network/api_transport.dart';
import '../../dtos/admin/update_price_request.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/shared/pagination_filter.dart';
import '../../filters/catalog/book_filter.dart';
import '../../filters/catalog/catalog_search_filter.dart';
import '../../dtos/admin/create_book_request.dart';
import '../../dtos/admin/catalog_profile_request.dart';
import '../../interfaces/network/downloaded_file.dart';
import '../../interfaces/network/upload_file.dart';
import '../../dtos/admin/permission_input.dart';
import '../../dtos/admin/role_input.dart';
import '../../dtos/admin/group_input.dart';
import '../../dtos/admin/user_access_input.dart';

class AdminApi {
  const AdminApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> inventory(BookFilter filter) =>
      client.get('/book/manage', query: filter.toQuery(), authenticated: true);

  Future<void> updatePrice(String slug, double price) async {
    await client.patch(
      '${ApiPaths.book(slug)}/price',
      body: UpdatePriceRequest(price).toJson(),
    );
  }

  Future<Map<String, dynamic>> access(String resource, int page) => client.get(
    '/access/$resource',
    query: PaginationFilter(page: page).toQuery(),
    authenticated: true,
  );

  Future<Map<String, dynamic>> createBook(CreateBookRequest input) =>
      client.post('/book', body: input.toJson());

  Future<Map<String, dynamic>> createProfile(
    String kind,
    CatalogProfileRequest input,
  ) => client.post('/$kind', body: input.toJson());

  Future<Map<String, dynamic>> catalogProfiles(
    String kind,
    CatalogSearchFilter filter,
  ) => client.get('/$kind', query: filter.toQuery());

  Future<Map<String, dynamic>> categories(CatalogSearchFilter filter) =>
      client.get('/categories', query: filter.toQuery());

  Future<Map<String, dynamic>> createCategory(String name) =>
      client.post('/categories', body: {'name': name});

  Future<Map<String, dynamic>> topCategories(int page, String sort) =>
      client.get(
        '/categories/top',
        query: {'page': '$page', 'per_page': '6', 'sort': sort},
      );

  Future<Map<String, dynamic>> countries(int page) => client.get(
    '/countries',
    query: PaginationFilter(page: page, perPage: 50).toQuery(),
  );

  Future<Map<String, dynamic>> syncCountries() =>
      client.post('/countries/sync');

  Future<Map<String, dynamic>> importBooks(UploadFile file) =>
      client.upload('/book/import', [file], fieldName: 'file');

  Future<DownloadedFile> exportBooks(String format, List<int> ids) =>
      client.download(
        '/book/export',
        fileName: 'library-books.$format',
        query: {'format': format, if (ids.isNotEmpty) 'ids': ids.join(',')},
      );

  Future<Map<String, dynamic>> bulkBooks(List<int> ids, String action) =>
      client.post('/book/bulk', body: {'ids': ids, 'action': action});

  Future<Map<String, dynamic>> deleteBook(String slug) =>
      client.delete(ApiPaths.book(slug));

  Future<Map<String, dynamic>> savePermission(
    PermissionInput input,
    String? key,
  ) => key == null
      ? client.post('/access/permissions', body: input.toJson())
      : client.put(
          '/access/permissions/${Uri.encodeComponent(key)}',
          body: input.toJson(),
        );

  Future<Map<String, dynamic>> saveRole(RoleInput input, String? key) =>
      key == null
      ? client.post('/access/roles', body: input.toJson())
      : client.put(
          '/access/roles/${Uri.encodeComponent(key)}',
          body: input.toJson(),
        );

  Future<Map<String, dynamic>> saveGroup(GroupInput input, int? id) =>
      id == null
      ? client.post('/access/groups', body: input.toJson())
      : client.put('/access/groups/$id', body: input.toJson());

  Future<Map<String, dynamic>> saveUser(int id, UserAccessInput input) =>
      client.put('/access/users/$id', body: input.toJson());

  Future<Map<String, dynamic>> deleteAccess(String resource, String id) =>
      client.delete('/access/$resource/${Uri.encodeComponent(id)}');
}
