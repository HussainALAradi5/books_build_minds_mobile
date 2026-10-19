import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:books_build_minds_mobile/core/network/api_client.dart';
import 'package:books_build_minds_mobile/features/catalog/domain/book.dart';
import 'package:books_build_minds_mobile/features/catalog/domain/book_condition.dart';
import 'package:books_build_minds_mobile/features/catalog/presentation/widgets/book_card.dart';

void main() {
  testWidgets('book card shows API data, condition, and action', (
    tester,
  ) async {
    var tapped = false;
    const book = Book(
      bookId: 1,
      slug: 'a-book',
      title: 'A Book',
      author: 'A Reader',
      publisher: 'A Press',
      price: 5.25,
      copiesTotal: 2,
      availableCopies: 1,
      averageRating: 4.5,
      condition: BookCondition.good,
    );
    final api = ApiClient(Uri.parse('https://example.test'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              height: 360,
              child: BookCard(book: book, api: api, onTap: () => tapped = true),
            ),
          ),
        ),
      ),
    );
    expect(find.text('A Book'), findsWidgets);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('5.250 BHD'), findsOneWidget);
    await tester.tap(find.byType(BookCard));
    expect(tapped, isTrue);
    api.close();
  });
}
