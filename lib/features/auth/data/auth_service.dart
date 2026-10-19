import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../domain/login_result.dart';
import '../domain/user_profile.dart';

class AuthService {
  AuthService(this._api, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  Future<LoginResult> login(String identifier, String password) async =>
      LoginResult.fromJson(
        await _api.post(
          '/login',
          body: {'identifier': identifier, 'password': password},
          authenticated: false,
        ),
      );

  Future<void> register(String userName, String email, String password) async {
    await _api.post(
      '/register',
      body: {'user_name': userName, 'email': email, 'password': password},
      authenticated: false,
    );
  }

  Future<void> requestReset(String identifier) async {
    await _api.post(
      '/password-reset/request',
      body: {'identifier': identifier},
      authenticated: false,
    );
  }

  Future<void> confirmReset(
    String identifier,
    String code,
    String newPassword,
  ) async {
    await _api.post(
      '/password-reset/confirm',
      body: {
        'identifier': identifier,
        'code': code,
        'new_password': newPassword,
      },
      authenticated: false,
    );
  }

  Future<UserProfile> profile(int userId) async => UserProfile.fromJson(
    await _api.get('/profile/$userId', authenticated: true),
  );

  Future<void> logout() async {
    await _api.post('/logout');
  }

  Future<void> save(LoginResult result) async {
    await _storage.write(key: 'library_token', value: result.token);
    await _storage.write(key: 'library_user_id', value: '${result.userId}');
  }

  Future<LoginResult?> savedSession() async {
    final token = await _storage.read(key: 'library_token');
    final id = int.tryParse(await _storage.read(key: 'library_user_id') ?? '');
    return token == null || id == null ? null : LoginResult(token, id);
  }

  Future<void> clear() async {
    await _storage.delete(key: 'library_token');
    await _storage.delete(key: 'library_user_id');
  }
}
