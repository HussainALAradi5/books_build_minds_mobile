import 'package:file_picker/file_picker.dart';

import '../../interfaces/network/downloaded_file.dart';

Future<bool> saveDownloadedFile(DownloadedFile file) async {
  final extension = file.name.split('.').last.toLowerCase();
  final mime = switch (extension) {
    'pdf' => 'application/pdf',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'csv' => 'text/csv',
    _ => 'application/octet-stream',
  };
  final destination = await FilePicker.saveFile(
    dialogTitle: 'Save file',
    fileName: file.name,
    bytes: file.bytes,
    mimeType: mime,
    type: FileType.custom,
    allowedExtensions: [extension],
  );
  return destination != null;
}
