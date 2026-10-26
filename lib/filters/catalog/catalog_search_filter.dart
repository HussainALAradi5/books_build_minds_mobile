import '../shared/pagination_filter.dart';

class CatalogSearchFilter extends PaginationFilter {
  const CatalogSearchFilter({
    super.page = 1,
    super.perPage = 12,
    this.query = '',
  });
  final String query;

  @override
  Map<String, String> toQuery() => {...super.toQuery(), 'q': query.trim()};
}
