import 'package:flutter_test/flutter_test.dart';
import 'package:books_build_minds_mobile/models/shared/page_result.dart';
import 'package:books_build_minds_mobile/utils/shared/request_key.dart';
import 'package:books_build_minds_mobile/models/catalog/book.dart';
import 'package:books_build_minds_mobile/enums/catalog/book_condition.dart';
import 'package:books_build_minds_mobile/enums/catalog/book_sort.dart';
import 'package:books_build_minds_mobile/enums/shared/sort_direction.dart';
import 'package:books_build_minds_mobile/filters/shared/pagination_filter.dart';
import 'package:books_build_minds_mobile/filters/loans/loan_filter.dart';
import 'package:books_build_minds_mobile/filters/reviews/review_filter.dart';
import 'package:books_build_minds_mobile/enums/loans/loan_status.dart';
import 'package:books_build_minds_mobile/filters/catalog/book_filter.dart';
import 'package:books_build_minds_mobile/middleware/network/auth_header_middleware.dart';
import 'package:books_build_minds_mobile/dtos/auth/login_request.dart';
import 'package:books_build_minds_mobile/shared/network/api_failure.dart';

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
      minPrice: 2.5,
      maxPrice: 9.75,
      sort: BookSort.price,
      sortDirection: SortDirection.asc,
      page: 2,
      perPage: 10,
    );
    expect(filter.toQuery(), {
      'page': '2',
      'per_page': '10',
      'sort_direction': 'asc',
      'sort': 'price',
      'q': 'stories',
      'publisher': 'Avery',
      'condition': 'good',
      'min_price': '2.500',
      'max_price': '9.750',
    });
    expect(filter.copyWith(clearCondition: true).condition, isNull);
    expect(filter, isA<PaginationFilter>());
    expect(filter.copyWith(page: 3).sortDirection, SortDirection.asc);
  });

  test('shared pagination is inherited by loan and review filters', () {
    const loans = LoanFilter(page: 3, status: LoanStatus.active);
    const reviews = ReviewFilter(page: 2, includeDeleted: true);
    expect(loans, isA<PaginationFilter>());
    expect(loans.toQuery(), {
      'page': '3',
      'per_page': '12',
      'sort_direction': 'desc',
      'status': 'active',
    });
    expect(reviews.toQuery(), {
      'page': '2',
      'per_page': '5',
      'sort_direction': 'desc',
      'include_deleted': 'true',
    });
    expect(
      const PaginationFilter(page: 0, perPage: 100).toQuery()['page'],
      '1',
    );
    expect(
      const PaginationFilter(page: 0, perPage: 100).toQuery()['per_page'],
      '50',
    );
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

  test('auth middleware protects private requests and leaves public requests clean', () {
    String? token;
    final middleware = AuthHeaderMiddleware(() => token);
    final headers = <String, String>{};
    middleware.prepare(headers, authenticated: false);
    expect(headers.containsKey('Authorization'), isFalse);
    expect(
      () => middleware.prepare(headers, authenticated: true),
      throwsA(isA<ApiFailure>()),
    );
    token = 'example-token';
    middleware.prepare(headers, authenticated: true);
    expect(headers['Authorization'], 'Bearer example-token');
  });

  test(
    'login DTO sends the backend field names without changing the password',
    () {
      const request = LoginRequest(
        identifier: '  reader  ',
        password: ' pass123 ',
      );
      expect(request.toJson(), {
        'identifier': 'reader',
        'password': ' pass123 ',
      });
    },
  );
}
