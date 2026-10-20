import 'package:books_build_minds_mobile/app/library_app.dart';
import 'package:books_build_minds_mobile/services/auth/auth_service.dart';
import 'package:books_build_minds_mobile/widgets/catalog/book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'preview_fixtures.dart';
import 'preview_fonts.dart';

// Run: flutter test --update-goldens tool/capture_operation_previews.dart
// Sample API responses illustrate flows without creating real transactions.
void main() {
  testWidgets('capture library and book operation previews', (tester) async {
    await loadPreviewFonts(tester);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = PreviewApiClient();
    final session = PreviewSession(AuthService(api));
    addTearDown(api.close);
    session.signInPreview();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('operation-preview'),
        child: LibraryApp(api: api, session: session),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/transactions-light.png'),
    );
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/activity-light.png'),
    );

    await tester.tap(find.text('Explore').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BookCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrow'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/borrow-terms-light.png'),
    );
    await tester.tap(find.text('I accept the library terms'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/borrow-review-light.png'),
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/borrow-confirm-light.png'),
    );
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Purchase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I accept the current terms'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/purchase-checkout-light.png'),
    );
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I accept the current terms'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/rental-checkout-light.png'),
    );
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('operation-preview')),
      matchesGoldenFile('../screenshots/mobile/transactions-dark.png'),
    );
  });
}
