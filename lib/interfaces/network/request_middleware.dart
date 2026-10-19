abstract interface class RequestMiddleware {
  void prepare(Map<String, String> headers, {required bool authenticated});
}
