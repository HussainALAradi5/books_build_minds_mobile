class PageQuery {
  const PageQuery._();

  static Map<String, String> forPage(int page, {int? perPage}) => {
    'page': '${page < 1 ? 1 : page}',
    if (perPage != null) 'per_page': '${perPage.clamp(1, 50)}',
  };
}
