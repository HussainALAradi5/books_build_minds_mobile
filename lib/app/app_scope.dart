import 'package:flutter/widgets.dart';

import '../shared/network/api_client.dart';
import '../controllers/auth/session_controller.dart';

class AppScope extends InheritedNotifier<SessionController> {
  const AppScope({
    super.key,
    required this.api,
    required this.session,
    required super.child,
  }) : super(notifier: session);

  final ApiClient api;
  final SessionController session;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is required');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      api != oldWidget.api || super.updateShouldNotify(oldWidget);
}
