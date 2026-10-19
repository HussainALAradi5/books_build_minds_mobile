import '../../interfaces/network/request_middleware.dart';
import '../../shared/network/api_failure.dart';

class AuthHeaderMiddleware implements RequestMiddleware {
  const AuthHeaderMiddleware(this.token);

  final String? Function() token;

  @override
  void prepare(Map<String, String> headers, {required bool authenticated}) {
    if (!authenticated) return;
    final value = token();
    if (value == null || value.isEmpty) {
      throw const ApiFailure('Please sign in to continue', statusCode: 401);
    }
    headers['Authorization'] = 'Bearer $value';
  }
}
