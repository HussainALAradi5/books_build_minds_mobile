import 'package:flutter/material.dart';

import './app/library_app.dart';
import './shared/config/app_config.dart';
import './shared/network/api_client.dart';
import './services/auth/auth_service.dart';
import './controllers/auth/session_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final api = ApiClient(config.apiOrigin);
  final session = SessionController(AuthService(api));
  api.tokenProvider = () => session.token;
  runApp(LibraryApp(api: api, session: session));
  session.restore();
}
