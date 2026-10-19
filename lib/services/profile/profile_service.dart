import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/profile/profile_api.dart';
import '../../models/catalog/book.dart';
import '../../models/profile/library_activity.dart';

class ProfileService {
  ProfileService(ApiTransport client) : _api = ProfileApi(client);

  final ProfileApi _api;

  Future<PageResult<Book>> owned(int userId, int page) async =>
      PageResult.fromJson(await _api.owned(userId, page), Book.fromJson);

  Future<PageResult<LibraryActivity>> activities(int userId, int page) async =>
      PageResult.fromJson(
        await _api.activities(userId, page),
        LibraryActivity.fromJson,
      );
}
