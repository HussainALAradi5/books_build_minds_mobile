import '../../interfaces/network/api_transport.dart';
import '../../interfaces/network/upload_file.dart';
import '../../filters/shared/pagination_filter.dart';

class MediaApi {
  const MediaApi(this.client);
  final ApiTransport client;

  Future<Map<String, dynamic>> list(int bookId, int page) => client.get(
    '/media/books/$bookId',
    query: PaginationFilter(page: page).toQuery(),
  );

  Future<Map<String, dynamic>> uploadBook(int bookId, List<UploadFile> files) =>
      client.upload('/media/books/$bookId', files);

  Future<Map<String, dynamic>> uploadProfile(UploadFile file) =>
      client.upload('/media/profile-picture', [file]);
}
