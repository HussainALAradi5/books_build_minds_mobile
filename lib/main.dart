import 'package:flutter/material.dart';

import 'app/library_app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/session_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final api = ApiClient(config.apiOrigin);
  final session = SessionController(AuthService(api));
  api.tokenProvider = () => session.token;
  runApp(LibraryApp(api: api, session: session));
  session.restore();
}
