import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig(this.apiOrigin);

  final Uri apiOrigin;

  factory AppConfig.fromEnvironment() {
    const value = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5000',
    );
    final origin = Uri.parse(value);
    if (!origin.hasScheme || origin.host.isEmpty) {
      throw StateError('API_BASE_URL must be an absolute URL');
    }
    if (kReleaseMode && origin.scheme != 'https') {
      throw StateError('A release build requires an HTTPS API_BASE_URL');
    }
    return AppConfig(origin);
  }
}
