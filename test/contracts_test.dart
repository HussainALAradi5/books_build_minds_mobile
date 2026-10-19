import 'package:flutter_test/flutter_test.dart';
import 'package:books_build_minds_mobile/core/models/page_result.dart';
import 'package:books_build_minds_mobile/core/utils/request_key.dart';
import 'package:books_build_minds_mobile/features/catalog/domain/book.dart';
import 'package:books_build_minds_mobile/features/catalog/domain/book_condition.dart';
import 'package:books_build_minds_mobile/features/catalog/domain/book_filter.dart';

void main() {
  test('maps the server page and book condition', () {
    final page = PageResult.fromJson({
      'items': [
        {
          'book_id': 7,
          'slug': 'sample',
          'title': 'A Book',
          'author': 'Reader',
          'publisher': 'Press',
          'price': 5.25,
          'copies_total': 3,
          'available_copies': 2,
          'average_rating': 4.5,
          'condition': 'fair',
        },
      ],
      'pagination': {
        'page': 2,
        'pages': 3,
        'total': 7,
        'has_next': true,
        'has_previous': true,
      },
    }, Book.fromJson);

    expect(page.items.single.condition, BookCondition.fair);
    expect(page.items.single.availableCopies, 2);
    expect(page.hasNext, isTrue);
    expect(page.page, 2);
  });

  test('filter maps camelCase state to server query only once', () {
    final filter = BookFilter(
      query: '  stories  ',
      publisher: 'Avery',
      condition: BookCondition.good,
      page: 2,
      perPage: 10,
    );
    expect(filter.toQuery(), {
      'page': '2',
      'per_page': '10',
      'sort': 'recent',
      'q': 'stories',
      'publisher': 'Avery',
      'condition': 'good',
    });
    expect(filter.copyWith(clearCondition: true).condition, isNull);
  });

  test('checkout request keys have UUID v4 shape and change per workflow', () {
    final first = newRequestKey();
    final second = newRequestKey();
    expect(
      first,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(second, isNot(first));
  });
}
