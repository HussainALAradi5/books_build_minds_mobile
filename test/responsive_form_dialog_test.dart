import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:books_build_minds_mobile/widgets/shared/responsive_form_dialog.dart';
import 'package:books_build_minds_mobile/widgets/shared/responsive_field_row.dart';
import 'package:books_build_minds_mobile/widgets/admin/book_create_dialog.dart';
import 'package:books_build_minds_mobile/services/admin/admin_service.dart';
import 'package:books_build_minds_mobile/shared/network/api_client.dart';

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets('long form remains usable at $width dp', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ResponsiveFormDialog(
                    title: 'Add a book',
                    content: SizedBox(
                      width: 420,
                      child: Column(
                        children: List.generate(
                          12,
                          (index) => TextField(
                            decoration: InputDecoration(
                              labelText: 'Field $index',
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(onPressed: () {}, child: const Text('Save')),
                    ],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
      expect(find.byTooltip('Close Add a book'), findsOneWidget);
      if (width < 600) {
        expect(
          tester.getTopLeft(find.byType(TextField).first).dy,
          lessThan(160),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 390.0]) {
    testWidgets('short fields use available width at $width dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ResponsiveFieldRow(
                first: const TextField(
                  decoration: InputDecoration(labelText: 'Copies'),
                ),
                second: const TextField(
                  decoration: InputDecoration(labelText: 'Condition'),
                ),
              ),
            ),
          ),
        ),
      );
      final copiesTop = tester.getTopLeft(find.text('Copies')).dy;
      final conditionTop = tester.getTopLeft(find.text('Condition')).dy;
      if (width >= 380) {
        expect(conditionTop, copiesTop);
      } else {
        expect(conditionTop, greaterThan(copiesTop));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('book form pairs copies and condition on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(366, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = AdminService(ApiClient(Uri.parse('http://example.test')));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => BookCreateDialog(service: service),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Copies'), findsOneWidget);
    expect(find.text('Condition'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Copies')).dy,
      tester.getTopLeft(find.text('Condition')).dy,
    );
    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Title')).dy, greaterThan(56));
    expect(tester.takeException(), isNull);
  });
}
