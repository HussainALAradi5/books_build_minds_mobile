import '../../interfaces/network/api_transport.dart';
import '../../dtos/auth/login_request.dart';
import '../../dtos/auth/register_request.dart';
import '../../dtos/auth/password_reset_request.dart';
import '../../dtos/auth/password_reset_confirmation.dart';
import '../../shared/network/api_paths.dart';

class AuthApi {
  const AuthApi(this.client);

  final ApiTransport client;

  Future<Map<String, dynamic>> login(String identifier, String password) =>
      client.post(
        '/login',
        body: LoginRequest(identifier: identifier, password: password).toJson(),
        authenticated: false,
      );

  Future<void> register(String userName, String email, String password) async {
    await client.post(
      '/register',
      body: RegisterRequest(
        userName: userName,
        email: email,
        password: password,
      ).toJson(),
      authenticated: false,
    );
  }

  Future<void> requestReset(String identifier) async {
    await client.post(
      '/password-reset/request',
      body: PasswordResetRequest(identifier: identifier).toJson(),
      authenticated: false,
    );
  }

  Future<void> confirmReset(
    String identifier,
    String code,
    String newPassword,
  ) async {
    await client.post(
      '/password-reset/confirm',
      body: PasswordResetConfirmation(
        identifier: identifier,
        code: code,
        newPassword: newPassword,
      ).toJson(),
      authenticated: false,
    );
  }

  Future<Map<String, dynamic>> profile(int userId) =>
      client.get(ApiPaths.profile(userId), authenticated: true);

  Future<void> logout() async {
    await client.post('/logout');
  }
}
