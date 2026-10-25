import '../../apis/media/media_api.dart';
import '../../interfaces/network/api_transport.dart';
import '../../interfaces/network/upload_file.dart';
import '../../models/media/media_item.dart';
import '../../models/shared/page_result.dart';

class MediaService {
  MediaService(ApiTransport client) : _api = MediaApi(client);
  final MediaApi _api;

  Future<PageResult<MediaItem>> list(int bookId, int page) async =>
      PageResult.fromJson(await _api.list(bookId, page), MediaItem.fromJson);

  Future<void> uploadBook(int bookId, List<UploadFile> files) async {
    await _api.uploadBook(bookId, files);
  }

  Future<void> uploadProfile(UploadFile file) async {
    await _api.uploadProfile(file);
  }
}
