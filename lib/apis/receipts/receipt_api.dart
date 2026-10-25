import '../../interfaces/network/api_transport.dart';
import '../../interfaces/network/downloaded_file.dart';
import '../../shared/network/api_paths.dart';

class ReceiptApi {
  const ReceiptApi(this.client);
  final ApiTransport client;

  Future<DownloadedFile> transaction(String id) => client.download(
    '${ApiPaths.transaction(id)}/receipt',
    fileName: 'receipt-$id.pdf',
    expectedMimeType: 'application/pdf',
  );
}
