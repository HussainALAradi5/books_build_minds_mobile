import 'package:books_build_minds_mobile/app/app_scope.dart';
import 'package:books_build_minds_mobile/controllers/auth/session_controller.dart';
import 'package:books_build_minds_mobile/enums/auth/user_role.dart';
import 'package:books_build_minds_mobile/models/auth/user_profile.dart';
import 'package:books_build_minds_mobile/services/auth/auth_service.dart';
import 'package:books_build_minds_mobile/shared/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('screens depending on AppScope update after sign-in', (
    tester,
  ) async {
    final api = ApiClient(Uri.parse('https://example.test'));
    final session = _TestSession(AuthService(api));
    addTearDown(api.close);
    addTearDown(session.dispose);

    await tester.pumpWidget(
      AppScope(
        api: api,
        session: session,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Text(
                AppScope.of(context).session.user?.userName ?? 'guest',
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('guest'), findsOneWidget);

    session.signInPreview();
    await tester.pump();
    expect(find.text('reader'), findsOneWidget);
    expect(find.text('guest'), findsNothing);
  });
}

class _TestSession extends SessionController {
  _TestSession(super.auth);

  void signInPreview() {
    user = const UserProfile(
      userId: 1,
      userName: 'reader',
      email: 'reader@example.test',
      role: UserRole.client,
      permissions: {},
      purchasedBookIds: {},
    );
    notifyListeners();
  }
}
