class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.pages,
    required this.total,
    required this.hasNext,
    required this.hasPrevious,
  });

  final List<T> items;
  final int page;
  final int pages;
  final int total;
  final bool hasNext;
  final bool hasPrevious;

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return PageResult(
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(parse)
          .toList(),
      page: pagination['page'] as int? ?? 1,
      pages: pagination['pages'] as int? ?? 0,
      total: pagination['total'] as int? ?? 0,
      hasNext: pagination['has_next'] as bool? ?? false,
      hasPrevious: pagination['has_previous'] as bool? ?? false,
    );
  }
}
