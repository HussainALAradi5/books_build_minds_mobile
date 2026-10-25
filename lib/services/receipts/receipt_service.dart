import '../../apis/receipts/receipt_api.dart';
import '../../interfaces/network/api_transport.dart';
import '../../utils/shared/save_downloaded_file.dart';

class ReceiptService {
  ReceiptService(ApiTransport client) : _api = ReceiptApi(client);
  final ReceiptApi _api;

  Future<bool> saveTransaction(String id) async =>
      saveDownloadedFile(await _api.transaction(id));
}
