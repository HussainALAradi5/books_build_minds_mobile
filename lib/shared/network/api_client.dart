import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../interfaces/network/api_transport.dart';
import '../../interfaces/network/request_middleware.dart';
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
