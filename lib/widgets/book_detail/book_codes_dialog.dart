import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/book_detail/book_codes.dart';
import '../../services/book_detail/book_detail_service.dart';

class BookCodesDialog extends StatelessWidget {
  const BookCodesDialog({super.key, required this.service, required this.slug});
  final BookDetailService service;
  final String slug;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Library codes'),
    content: SizedBox(
      width: 320,
      child: FutureBuilder<BookCodes>(
        future: service.codes(slug),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final codes = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.memory(
                  codes.qrImage,
                  width: 180,
                  height: 180,
                  semanticsLabel: 'QR code for this book',
                ),
                const SizedBox(height: 12),
                SelectableText(codes.bookUrl, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                SvgPicture.memory(
                  codes.barcodeImage,
                  width: 260,
                  height: 90,
                  semanticsLabel: 'Barcode for this book',
                ),
                const SizedBox(height: 7),
                SelectableText(codes.barcodeValue),
              ],
            ),
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}
