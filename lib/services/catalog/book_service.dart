import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/catalog/book_api.dart';
import '../../models/catalog/book.dart';
import '../../filters/catalog/book_filter.dart';
import '../../filters/catalog/catalog_search_filter.dart';
import '../../models/catalog/category.dart';
import '../../models/catalog/catalog_person.dart';
import '../../models/catalog/top_category_group.dart';

class BookService {
  BookService(ApiTransport client) : _api = BookApi(client);

  final BookApi _api;

  Future<PageResult<Book>> list(BookFilter filter) async =>
      PageResult.fromJson(await _api.list(filter.toQuery()), Book.fromJson);

  Future<Book> detail(String slug) async =>
      Book.fromJson(await _api.detail(slug));

  Future<PageResult<Category>> categories(CatalogSearchFilter filter) async =>
      PageResult.fromJson(await _api.categories(filter), Category.fromJson);

  Future<PageResult<CatalogPerson>> catalogProfiles(
    String kind,
    CatalogSearchFilter filter,
  ) async => PageResult.fromJson(
    await _api.catalogProfiles(kind, filter),
    CatalogPerson.fromJson,
  );

  Future<PageResult<TopCategoryGroup>> topCategories(
    int page,
    String sort,
  ) async => PageResult.fromJson(
    await _api.topCategories(page, sort),
    TopCategoryGroup.fromJson,
  );
}
