class ApiPaths {
  const ApiPaths._();

  static String book(String slug) => '/book/${Uri.encodeComponent(slug)}';
  static String profile(int userId) => '/profile/$userId';
  static String transaction(String id) =>
      '/transactions/${Uri.encodeComponent(id)}';
}
