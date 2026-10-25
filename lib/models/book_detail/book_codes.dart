import 'dart:convert';
import 'dart:typed_data';

class BookCodes {
  const BookCodes({
    required this.bookUrl,
    required this.barcodeValue,
    required this.qrImage,
    required this.barcodeImage,
  });

  final String bookUrl;
  final String barcodeValue;
  final Uint8List qrImage;
  final Uint8List barcodeImage;

  factory BookCodes.fromJson(Map<String, dynamic> json) => BookCodes(
    bookUrl: json['book_url'] as String,
    barcodeValue: json['barcode_value'] as String,
    qrImage: _svg(json['qr_image'] as String),
    barcodeImage: _svg(json['barcode_image'] as String),
  );

  static Uint8List _svg(String dataUrl) {
    final marker = 'base64,';
    final index = dataUrl.indexOf(marker);
    if (!dataUrl.startsWith('data:image/svg+xml;') || index < 0) {
      throw const FormatException('Invalid book code image');
    }
    return base64Decode(dataUrl.substring(index + marker.length));
  }
}
