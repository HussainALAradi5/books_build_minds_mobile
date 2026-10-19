import '../../interfaces/network/api_transport.dart';
import '../../shared/network/api_paths.dart';
import '../../filters/shared/pagination_filter.dart';

class ProfileApi {
  const ProfileApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> owned(int userId, int page) => client.get(
    '${ApiPaths.profile(userId)}/books',
    query: PaginationFilter(page: page).toQuery(),
    authenticated: true,
  );

  Future<Map<String, dynamic>> activities(int userId, int page) => client.get(
    '${ApiPaths.profile(userId)}/activities',
    query: PaginationFilter(page: page).toQuery(),
    authenticated: true,
  );
}
