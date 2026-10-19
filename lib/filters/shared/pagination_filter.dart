import '../../enums/shared/sort_direction.dart';
import '../../utils/shared/page_query.dart';

class PaginationFilter {
  const PaginationFilter({
    this.page = 1,
    this.perPage = 12,
    this.sortDirection = SortDirection.desc,
  });

  final int page;
  final int perPage;
  final SortDirection sortDirection;

  Map<String, String> toQuery() => {
    ...PageQuery.forPage(page, perPage: perPage),
    'sort_direction': sortDirection.name,
  };
}
