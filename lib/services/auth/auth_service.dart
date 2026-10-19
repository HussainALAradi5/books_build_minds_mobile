import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../interfaces/network/api_transport.dart';
import '../../apis/auth/auth_api.dart';
import '../../models/auth/login_result.dart';
import '../../models/auth/user_profile.dart';

class AuthService {
  AuthService(ApiTransport client, {FlutterSecureStorage? storage})
    : _authApi = AuthApi(client),
      _storage = storage ?? const FlutterSecureStorage();

  final AuthApi _authApi;
  final FlutterSecureStorage _storage;

  Future<LoginResult> login(String identifier, String password) async =>
      LoginResult.fromJson(await _authApi.login(identifier, password));

  Future<void> register(String userName, String email, String password) async {
    await _authApi.register(userName, email, password);
  }

  Future<void> requestReset(String identifier) async {
    await _authApi.requestReset(identifier);
  }

  Future<void> confirmReset(
    String identifier,
    String code,
    String newPassword,
  ) async {
    await _authApi.confirmReset(identifier, code, newPassword);
  }

  Future<UserProfile> profile(int userId) async =>
      UserProfile.fromJson(await _authApi.profile(userId));

  Future<void> logout() async {
    await _authApi.logout();
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
