import '../../enums/catalog/book_condition.dart';
import '../../enums/catalog/book_sort.dart';
import '../../enums/shared/sort_direction.dart';
import '../shared/pagination_filter.dart';

class BookFilter extends PaginationFilter {
  const BookFilter({
    this.query = '',
    this.publisher = '',
    this.category = '',
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.sort = BookSort.recent,
    super.page,
    super.perPage,
    super.sortDirection,
  });

  final String query;
  final String publisher;
  final String category;
  final BookCondition? condition;
  final double? minPrice;
  final double? maxPrice;
  final BookSort sort;

  BookFilter copyWith({
    String? query,
    String? publisher,
    String? category,
    BookCondition? condition,
    bool clearCondition = false,
    double? minPrice,
    double? maxPrice,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    BookSort? sort,
    int? page,
    int? perPage,
    SortDirection? sortDirection,
  }) => BookFilter(
    query: query ?? this.query,
    publisher: publisher ?? this.publisher,
    category: category ?? this.category,
    condition: clearCondition ? null : condition ?? this.condition,
    minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
    maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
    sort: sort ?? this.sort,
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
    sortDirection: sortDirection ?? this.sortDirection,
  );

  @override
  Map<String, String> toQuery() => {
    ...super.toQuery(),
    'sort': sort.wireValue,
    if (query.trim().isNotEmpty) 'q': query.trim(),
    if (publisher.isNotEmpty) 'publisher': publisher,
    if (category.isNotEmpty) 'category': category,
    if (condition != null) 'condition': condition!.wireValue,
    if (minPrice != null) 'min_price': minPrice!.toStringAsFixed(3),
    if (maxPrice != null) 'max_price': maxPrice!.toStringAsFixed(3),
  };
}
