import '../../../core/models/page_result.dart';
import '../../../core/network/api_client.dart';
import '../../catalog/domain/book.dart';
import '../domain/library_activity.dart';

class ProfileService {
  const ProfileService(this._api);

  final ApiClient _api;

  Future<PageResult<Book>> owned(int userId, int page) async =>
      PageResult.fromJson(
        await _api.get(
          '/profile/$userId/books',
          query: {'page': '$page'},
          authenticated: true,
        ),
        Book.fromJson,
      );

  Future<PageResult<LibraryActivity>> activities(int userId, int page) async =>
      PageResult.fromJson(
        await _api.get(
          '/profile/$userId/activities',
          query: {'page': '$page'},
          authenticated: true,
        ),
        LibraryActivity.fromJson,
      );
}
