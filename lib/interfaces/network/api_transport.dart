import 'downloaded_file.dart';
import 'upload_file.dart';

abstract interface class ApiTransport {
  Uri endpointUri(String path);
  Uri assetUri(String path);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = false,
  });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  });

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  });

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  });

  Future<Map<String, dynamic>> delete(String path);

  Future<DownloadedFile> download(
    String path, {
    required String fileName,
    String? expectedMimeType,
    Map<String, String>? query,
  });

  Future<Map<String, dynamic>> upload(
    String path,
    List<UploadFile> files, {
    String fieldName = 'files',
  });
}
