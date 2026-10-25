import 'dart:typed_data';

class DownloadedFile {
  const DownloadedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
