import '../shared/pagination_filter.dart';

class ReviewFilter extends PaginationFilter {
  const ReviewFilter({
    this.includeDeleted = false,
    super.page,
    super.perPage = 5,
    super.sortDirection,
  });

  final bool includeDeleted;

  @override
  Map<String, String> toQuery() => {
    ...super.toQuery(),
    'include_deleted': '$includeDeleted',
  };
}
