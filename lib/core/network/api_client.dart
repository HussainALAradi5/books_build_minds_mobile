import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_failure.dart';

typedef TokenProvider = String? Function();

class ApiClient {
  ApiClient(this.origin, {HttpClient? httpClient})
    : _http = httpClient ?? HttpClient();

  final Uri origin;
  final HttpClient _http;
  TokenProvider? tokenProvider;

  Uri uri(String path, [Map<String, String>? query]) => origin.replace(
    path: '/api${path.startsWith('/') ? path : '/$path'}',
    queryParameters: query?.isEmpty == true ? null : query,
  );

  Uri assetUri(String path) => origin.resolve(path);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = false,
  }) => request('GET', path, query: query, authenticated: authenticated);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => request('POST', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => request('PUT', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => request('PATCH', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> delete(String path) =>
      request('DELETE', path, authenticated: true);

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final token = tokenProvider?.call();
    if (authenticated && (token == null || token.isEmpty)) {
      throw const ApiFailure('Please sign in to continue', statusCode: 401);
    }
    try {
      final connection = await _http
          .openUrl(method, uri(path, query))
          .timeout(const Duration(seconds: 12));
      connection.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (authenticated) {
        connection.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $token',
        );
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
