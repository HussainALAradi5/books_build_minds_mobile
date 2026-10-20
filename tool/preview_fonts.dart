import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

Future<void> loadPreviewFonts(WidgetTester tester) async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError('Set FLUTTER_ROOT before capturing previews.');
  }
  await tester.runAsync(() async {
    for (final (path, family) in [
      ('roboto-regular.ttf', 'Roboto'),
      ('roboto-bold.ttf', 'serif'),
      ('materialicons-regular.otf', 'MaterialIcons'),
    ]) {
      final file = File('$root/bin/cache/artifacts/material_fonts/$path');
      await ui.loadFontFromList(await file.readAsBytes(), fontFamily: family);
    }
  });
}
