import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../interfaces/network/api_transport.dart';
import '../../interfaces/network/downloaded_file.dart';
import '../../interfaces/network/request_middleware.dart';
import '../../interfaces/network/upload_file.dart';
import '../../middleware/network/auth_header_middleware.dart';
import './api_failure.dart';

typedef TokenProvider = String? Function();

class ApiClient implements ApiTransport {
  ApiClient(
    this.origin, {
    HttpClient? httpClient,
    List<RequestMiddleware>? middleware,
  }) : _http = httpClient ?? HttpClient(),
       _customMiddleware = middleware;

  final Uri origin;
  final HttpClient _http;
  final List<RequestMiddleware>? _customMiddleware;
  TokenProvider? tokenProvider;

  Uri uri(String path, [Map<String, String>? query]) => origin.replace(
    path: '/api${path.startsWith('/') ? path : '/$path'}',
    queryParameters: query?.isEmpty == true ? null : query,
  );

  @override
  Uri endpointUri(String path) => uri(path);

  @override
  Uri assetUri(String path) => origin.resolve(path);

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = false,
  }) => request('GET', path, query: query, authenticated: authenticated);

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => request('POST', path, body: body, authenticated: authenticated);

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => request('PUT', path, body: body, authenticated: authenticated);

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => request('PATCH', path, body: body, authenticated: authenticated);

  @override
  Future<Map<String, dynamic>> delete(String path) =>
      request('DELETE', path, authenticated: true);

  @override
  Future<DownloadedFile> download(
    String path, {
    required String fileName,
    String? expectedMimeType,
    Map<String, String>? query,
  }) async {
    final headers = _headers(authenticated: true);
    try {
      final connection = await _http
          .openUrl('GET', uri(path, query))
          .timeout(const Duration(seconds: 12));
      for (final entry in headers.entries) {
        connection.headers.set(entry.key, entry.value);
      }
      final response = await connection.close().timeout(
        const Duration(seconds: 30),
      );
      final bytes = await _readBytes(response);
      if (response.statusCode >= 400) {
        throw _responseFailure(response.statusCode, bytes);
      }
      if (expectedMimeType != null &&
          response.headers.contentType?.mimeType != expectedMimeType) {
        throw const ApiFailure('The server returned an unexpected file type.');
      }
      return DownloadedFile(name: fileName, bytes: bytes);
    } on ApiFailure {
      rethrow;
    } on SocketException {
      throw const ApiFailure(
        'Cannot reach the library server.',
        isNetworkError: true,
      );
    } on TimeoutException {
      throw const ApiFailure(
        'The download took too long.',
        isNetworkError: true,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> upload(
    String path,
    List<UploadFile> files, {
    String fieldName = 'files',
  }) async {
    if (files.isEmpty || files.length > 10) {
      throw const ApiFailure('Choose between 1 and 10 files.');
    }
    for (final file in files) {
      if (file.bytes.isEmpty || file.bytes.length > 25 * 1024 * 1024) {
        throw const ApiFailure('Each file must be between 1 byte and 25 MB.');
      }
    }
    final headers = _headers(authenticated: true);
    final boundary =
        'books-build-minds-${DateTime.now().microsecondsSinceEpoch}';
    try {
      final connection = await _http
          .openUrl('POST', uri(path))
          .timeout(const Duration(seconds: 12));
      for (final entry in headers.entries) {
        connection.headers.set(entry.key, entry.value);
      }
      connection.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      for (final file in files) {
        final safeName = file.name.replaceAll(RegExp(r'[\r\n"\\]'), '_');
        connection.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="$fieldName"; filename="$safeName"\r\n'
            'Content-Type: ${file.mimeType}\r\n\r\n',
          ),
        );
        connection.add(file.bytes);
        connection.add(utf8.encode('\r\n'));
      }
      connection.add(utf8.encode('--$boundary--\r\n'));
      final response = await connection.close().timeout(
        const Duration(seconds: 40),
      );
      final bytes = await _readBytes(response);
      if (response.statusCode >= 400) {
        throw _responseFailure(response.statusCode, bytes);
      }
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } on ApiFailure {
      rethrow;
    } on SocketException {
      throw const ApiFailure(
        'Cannot reach the library server.',
        isNetworkError: true,
      );
    } on TimeoutException {
      throw const ApiFailure('The upload took too long.', isNetworkError: true);
    } on FormatException {
      throw const ApiFailure('The server returned an unexpected response.');
    }
  }

  Map<String, String> _headers({required bool authenticated}) {
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
    };
    for (final middleware
        in _customMiddleware ??
            [AuthHeaderMiddleware(() => tokenProvider?.call())]) {
      middleware.prepare(headers, authenticated: authenticated);
    }
    return headers;
  }

  Future<Uint8List> _readBytes(HttpClientResponse response) async {
    const maxBytes = 25 * 1024 * 1024;
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const ApiFailure('The server file is too large.');
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  ApiFailure _responseFailure(int status, Uint8List bytes) {
    try {
      final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return ApiFailure(
        data['error'] as String? ?? 'Request failed',
        statusCode: status,
      );
    } catch (_) {
      return ApiFailure('Request failed', statusCode: status);
    }
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
    };
    for (final middleware
        in _customMiddleware ??
            [AuthHeaderMiddleware(() => tokenProvider?.call())]) {
      middleware.prepare(headers, authenticated: authenticated);
    }
    try {
      final connection = await _http
          .openUrl(method, uri(path, query))
          .timeout(const Duration(seconds: 12));
      for (final entry in headers.entries) {
        connection.headers.set(entry.key, entry.value);
      }
      if (body != null) {
        connection.headers.contentType = ContentType.json;
        connection.write(jsonEncode(body));
      }
      final response = await connection.close().timeout(
        const Duration(seconds: 20),
      );
      final text = await utf8.decoder.bind(response).join();
      final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
      final data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};
      if (response.statusCode >= 400) {
        throw ApiFailure(
          data['error'] is String ? data['error'] as String : 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on ApiFailure {
      rethrow;
    } on SocketException {
      throw const ApiFailure(
        'Cannot reach the library server. Check your connection.',
        isNetworkError: true,
      );
    } on HandshakeException {
      throw const ApiFailure(
        'A secure connection could not be established.',
        isNetworkError: true,
      );
    } on FormatException {
      throw const ApiFailure('The server returned an unexpected response.');
    } on TimeoutException {
      throw const ApiFailure(
        'The server took too long to respond.',
        isNetworkError: true,
      );
    }
  }

  void close() => _http.close(force: true);
}
