import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:books_build_minds_mobile/interfaces/network/upload_file.dart';
import 'package:books_build_minds_mobile/shared/network/api_client.dart';
import 'package:books_build_minds_mobile/shared/network/api_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'authenticated multipart upload and binary receipt match API contract',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final client = ApiClient(Uri.parse('http://127.0.0.1:${server.port}'))
        ..tokenProvider = () => 'test-token';
      final requests = <String>[];
      final handling = server.listen((request) async {
        requests.add('${request.method} ${request.uri.path}');
        expect(request.headers.value('authorization'), 'Bearer test-token');
        if (request.uri.path == '/api/media/books/7') {
          final body = await utf8.decoder.bind(request).join();
          expect(request.headers.contentType?.mimeType, 'multipart/form-data');
          expect(body, contains('name="files"; filename="cover.png"'));
          expect(body, contains('Content-Type: image/png'));
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'items': []}));
        } else {
          request.response.headers.contentType = ContentType(
            'application',
            'pdf',
          );
          request.response.add([37, 80, 68, 70]);
        }
        await request.response.close();
      });
      try {
        await client.upload('/media/books/7', [
          UploadFile(
            name: 'cover.png',
            bytes: Uint8List.fromList([1, 2, 3]),
            mimeType: 'image/png',
          ),
        ]);
        final receipt = await client.download(
          '/transactions/abc/receipt',
          fileName: 'receipt.pdf',
          expectedMimeType: 'application/pdf',
        );
        expect(receipt.bytes, [37, 80, 68, 70]);
        expect(requests, [
          'POST /api/media/books/7',
          'GET /api/transactions/abc/receipt',
        ]);
      } finally {
        client.close();
        await handling.cancel();
        await server.close(force: true);
      }
    },
  );

  test('upload rejects an empty file before sending a request', () async {
    final client = ApiClient(Uri.parse('http://127.0.0.1:1'));
    expect(
      () => client.upload('/media/profile-picture', [
        UploadFile(
          name: 'empty.png',
          bytes: Uint8List(0),
          mimeType: 'image/png',
        ),
      ]),
      throwsA(isA<ApiFailure>()),
    );
    client.close();
  });
}
