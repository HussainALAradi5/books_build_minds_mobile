import 'book_condition.dart';

class BookFilter {
  const BookFilter({
    this.query = '',
    this.publisher = '',
    this.condition,
    this.sort = 'recent',
    this.page = 1,
    this.perPage = 12,
  });

  final String query;
  final String publisher;
  final BookCondition? condition;
  final String sort;
  final int page;
  final int perPage;

  BookFilter copyWith({
    String? query,
    String? publisher,
    BookCondition? condition,
    bool clearCondition = false,
    String? sort,
    int? page,
  }) => BookFilter(
    query: query ?? this.query,
    publisher: publisher ?? this.publisher,
    condition: clearCondition ? null : condition ?? this.condition,
    sort: sort ?? this.sort,
    page: page ?? this.page,
    perPage: perPage,
  );

  Map<String, String> toQuery() => {
    'page': '$page',
    'per_page': '$perPage',
    'sort': sort,
    if (query.trim().isNotEmpty) 'q': query.trim(),
    if (publisher.isNotEmpty) 'publisher': publisher,
    if (condition != null) 'condition': condition!.wireValue,
  };
}
