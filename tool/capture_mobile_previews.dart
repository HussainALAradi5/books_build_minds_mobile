import 'package:books_build_minds_mobile/app/library_app.dart';
import 'package:books_build_minds_mobile/services/auth/auth_service.dart';
import 'package:books_build_minds_mobile/widgets/catalog/book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'preview_fixtures.dart';
import 'preview_fonts.dart';

// Run: flutter test --update-goldens tool/capture_mobile_previews.dart
// These are rendered app previews with deterministic sample API responses.
void main() {
  testWidgets('capture mobile catalog and detail previews', (tester) async {
    await loadPreviewFonts(tester);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = PreviewApiClient();
    final session = PreviewSession(AuthService(api));
    addTearDown(api.close);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('mobile-preview'),
        child: LibraryApp(api: api, session: session),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/catalog-light.png'),
    );

    tester.view.physicalSize = const Size(320, 700);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/catalog-small-android.png'),
    );
    tester.view.physicalSize = const Size(360, 780);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/catalog-standard-android.png'),
    );
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/filters-light.png'),
    );
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sign in'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/sign-in-light.png'),
    );
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/register-light.png'),
    );
    await tester.tap(find.text('Back to sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/password-reset-light.png'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/catalog-dark.png'),
    );

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/filters-dark.png'),
    );
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BookCard).first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/book-detail.png'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sign in'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/sign-in.png'),
    );
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/register.png'),
    );
    await tester.tap(find.text('Back to sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/password-reset.png'),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'preview@example.test',
    );
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/password-reset-code.png'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/catalog-list-light.png'),
    );
    await tester.tap(find.byTooltip('Grid view'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BookCard).first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/book-detail-light.png'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Magic7 Pro panel: 1280 × 2800 physical pixels. Android's chosen display
    // scaling may differ, so this 3× render checks the common ~427 dp width.
    tester.view.physicalSize = const Size(1280, 2800);
    tester.view.devicePixelRatio = 3;
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/honor-magic7-pro-catalog.png'),
    );
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/honor-magic7-pro-dark.png'),
    );
    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pumpAndSettle();

    session.signInPreview();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    expect(find.text('Your library'), findsOneWidget);
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/loans-signed-in.png'),
    );
    await tester.tap(find.text('Owned'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/owned-books.png'),
    );
    await tester.tap(find.text('Account').last);
    await tester.pumpAndSettle();
    expect(find.text('demo_client'), findsOneWidget);
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/profile-signed-in.png'),
    );
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/profile-signed-in-dark.png'),
    );
    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Loans'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('mobile-preview')),
      matchesGoldenFile('../screenshots/mobile/loans-signed-in-dark.png'),
    );
  });
}
