import 'dart:io';
import 'dart:ui' as ui;

import 'package:books_build_minds_mobile/app/library_app.dart';
import 'package:books_build_minds_mobile/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/preview_fixtures.dart';

void main() {
  testWidgets('theme button switches from a dark phone setting', (
    tester,
  ) async {
    final fontRoot = Platform.environment['FLUTTER_ROOT'];
    if (fontRoot == null) throw StateError('Set FLUTTER_ROOT for this test.');
    await tester.runAsync(() async {
      await ui.loadFontFromList(
        await File(
          '$fontRoot/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
        ).readAsBytes(),
        fontFamily: 'Roboto',
      );
      await ui.loadFontFromList(
        await File(
          '$fontRoot/bin/cache/artifacts/material_fonts/roboto-bold.ttf',
        ).readAsBytes(),
        fontFamily: 'serif',
      );
      await ui.loadFontFromList(
        await File(
          '$fontRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
        ).readAsBytes(),
        fontFamily: 'MaterialIcons',
      );
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final api = PreviewApiClient();
    final session = PreviewSession(AuthService(api));
    addTearDown(api.close);
    addTearDown(session.dispose);

    await tester.pumpWidget(LibraryApp(api: api, session: session));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Switch to light mode'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Switch to dark mode'), findsOneWidget);
  });
}
