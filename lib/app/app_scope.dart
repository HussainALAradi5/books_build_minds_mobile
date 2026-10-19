import 'package:flutter/widgets.dart';

import '../core/network/api_client.dart';
import '../features/auth/presentation/session_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.api,
    required this.session,
    required super.child,
  });

  final ApiClient api;
  final SessionController session;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is required');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      api != oldWidget.api || session != oldWidget.session;
}
