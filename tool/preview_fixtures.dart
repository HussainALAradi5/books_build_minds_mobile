import 'package:books_build_minds_mobile/controllers/auth/session_controller.dart';
import 'package:books_build_minds_mobile/enums/auth/user_role.dart';
import 'package:books_build_minds_mobile/models/auth/user_profile.dart';
import 'package:books_build_minds_mobile/shared/network/api_client.dart';

class PreviewSession extends SessionController {
  PreviewSession(super.auth);

  void signInPreview() {
    token = 'preview-only';
    user = const UserProfile(
      userId: 1,
      userName: 'demo_client',
      email: 'demo-client@example.test',
      role: UserRole.client,
      permissions: {},
      purchasedBookIds: {1},
    );
    notifyListeners();
  }
}

class PreviewApiClient extends ApiClient {
  PreviewApiClient() : super(Uri.parse('https://preview.example.test'));

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = false,
  }) async {
    if (path == '/') {
      return {
        'items': [
          _book('sapiens', 1, 'Sapiens', 'Yuval Noah Harari', 10.2),
          _book('deep-work', 2, 'Deep Work', 'Cal Newport', 6.8),
          _book('educated', 3, 'Educated', 'Tara Westover', 9.75),
        ],
        'pagination': {
          'page': 1,
          'pages': 1,
          'total': 3,
          'has_next': false,
          'has_previous': false,
        },
      };
    }
    if (path == '/book/sapiens') {
      return {
        ..._book('sapiens', 1, 'Sapiens', 'Yuval Noah Harari', 10.2),
        'description':
            'A brief history of humankind and the ideas that shaped our world.',
        'isbn': '9780062316097',
        'published_at': '2015-02-10',
      };
    }
    if (path == '/book/sapiens/review') {
      return {
        'items': <Map<String, dynamic>>[],
        'pagination': {
          'page': 1,
          'pages': 1,
          'total': 0,
          'has_next': false,
          'has_previous': false,
        },
      };
    }
    if (path == '/publishers') {
      return {
        'items': [
          {'name': 'Books Build Minds'},
        ],
      };
    }
    if (path == '/profile/1/loans') {
      return _page([
        {
          'loan_id': 7,
          'book_title': 'Sapiens',
          'book_slug': 'sapiens',
          'status': 'active',
          'loan_kind': 'borrow',
          'due_at': '2026-11-01T12:00:00Z',
        },
      ]);
    }
    if (path == '/profile/1/books') {
      return _page([_book('sapiens', 1, 'Sapiens', 'Yuval Noah Harari', 10.2)]);
    }
    if (path == '/profile/1/activities') {
      return _page([
        {
          'book_title': 'Sapiens',
          'action_type': 'borrowed',
          'occurred_at': '2026-10-18T12:00:00Z',
        },
        {
          'book_title': 'Deep Work',
          'action_type': 'purchased',
          'occurred_at': '2026-10-15T12:00:00Z',
        },
      ]);
    }
    if (path == '/transactions') {
      return _page([
        {
          'transaction_id': 'preview-purchase-1',
          'book_title': 'Deep Work',
          'kind': 'purchase',
          'status': 'completed',
          'amount_minor': 6800,
          'currency_scale': 1000,
        },
        {
          'transaction_id': 'preview-rental-1',
          'book_title': 'Educated',
          'kind': 'rental',
          'status': 'pending',
          'amount_minor': 1500,
          'currency_scale': 1000,
        },
      ]);
    }
    if (path == '/book/sapiens/quote') {
      return {
        'available_copies': 3,
        'borrow_days': 14,
        'rental_days': 7,
        'purchase_amount_minor': 10200,
        'rental_amount_minor': 2000,
        'currency_scale': 1000,
        'policy_version': 'preview-v1',
        'terms': [
          'Follow the current library policy for this book.',
          'Stock and price are checked again when you confirm.',
        ],
      };
    }
    if (path == '/book/sapiens/loan') {
      return {'loan': null};
    }
    throw StateError('No preview response for $path');
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    if (path == '/password-reset/request') return {};
    throw StateError('No preview response for POST $path');
  }

  Map<String, dynamic> _page(List<Map<String, dynamic>> items) => {
    'items': items,
    'pagination': {
      'page': 1,
      'pages': 1,
      'total': items.length,
      'has_next': false,
      'has_previous': false,
    },
  };

  Map<String, dynamic> _book(
    String slug,
    int id,
    String title,
    String author,
    double price,
  ) => {
    'book_id': id,
    'slug': slug,
    'title': title,
    'author': author,
    'publisher': 'Books Build Minds',
    'price': price,
    'copies_total': 4,
    'available_copies': 3,
    'average_rating': 4.8,
    'condition': 'good',
  };
}
