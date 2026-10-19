import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../shared/network/api_client.dart';
import '../../widgets/shared/book_cover.dart';
import '../../widgets/shared/state_panel.dart';
import '../../services/checkout/transaction_service.dart';
import '../../services/loans/loan_service.dart';
import '../../services/reviews/review_service.dart';
import '../../widgets/reviews/review_section.dart';
import '../../services/book_detail/book_detail_service.dart';
import '../../controllers/book_detail/book_detail_controller.dart';
import '../../widgets/book_detail/book_actions.dart';
import '../../widgets/book_detail/book_info_card.dart';
import '../../utils/book_detail/book_detail_actions.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  BookDetailController? controller;
  LoanService? loans;
  TransactionService? transactions;
  BookDetailService? bookDetails;
  ApiClient? api;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller != null) return;
    _createController();
  }

  void _createController() {
    final scope = AppScope.of(context);
    api = scope.api;
    loans = LoanService(scope.api);
    transactions = TransactionService(scope.api);
    bookDetails = BookDetailService(scope.api);
    controller = BookDetailController(
      widget.slug,
      bookDetails!,
      loans!,
      ReviewService(scope.api),
      scope.session.user,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller?.load());
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('The collection'),
      actions: [
        IconButton(
          onPressed: controller?.load,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh book',
        ),
      ],
    ),
    body: controller == null
        ? const Center(child: CircularProgressIndicator())
        : ListenableBuilder(
            listenable: controller!,
            builder: (context, _) {
              final state = controller!;
              final detail = state.detail;
              if (state.loading && detail == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (detail == null) {
                return StatePanel(
                  icon: Icons.menu_book_outlined,
                  title: 'This book is unavailable',
                  message: state.error ?? 'Please try again later.',
                  actionLabel: 'Try again',
                  onAction: state.load,
                );
              }
              final book = detail.book;
              final signedIn = state.user != null;
              return RefreshIndicator(
                onRefresh: state.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                  children: [
                    Text(
                      'THE COLLECTION / ${book.publisher.toUpperCase()}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'by ${book.author}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        Text(
                          ' ${book.averageRating.toStringAsFixed(1)} reader rating',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 700;
                        final information = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BookInfoCard(detail: detail),
                            const SizedBox(height: 13),
                            BookActions(
                              signedIn: signedIn,
                              available: book.availableCopies > 0,
                              hasLoan: state.currentLoan != null,
                              busy: state.busy,
                              onBorrow: actions.borrow,
                              onReturn: actions.returnBook,
                              onPurchase: () => actions.checkout('purchase'),
                              onRent: () => actions.checkout('rental'),
                              onPrint: actions.printBook,
                              onSignIn: actions.signIn,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 7,
                              children: [
                                if (detail.author != null)
                                  TextButton.icon(
                                    onPressed: () => actions.creator(
                                      'About the author',
                                      detail.author!,
                                    ),
                                    icon: const Icon(
                                      Icons.person_outline_rounded,
                                      size: 17,
                                    ),
                                    label: const Text('About the author'),
                                  ),
                                if (detail.publisher != null)
                                  TextButton.icon(
                                    onPressed: () => actions.creator(
                                      'About the publisher',
                                      detail.publisher!,
                                    ),
                                    icon: const Icon(
                                      Icons.apartment_rounded,
                                      size: 17,
                                    ),
                                    label: const Text('About the publisher'),
                                  ),
                              ],
                            ),
                          ],
                        );
                        if (!wide) {
                          return Column(
                            children: [
                              information,
                              const SizedBox(height: 17),
                              BookCover(book: book, api: api!, height: 295),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 245,
                              child: BookCover(
                                book: book,
                                api: api!,
                                height: 365,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: information),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    ReviewSection(controller: state),
                  ],
                ),
              );
            },
          ),
  );

  BookDetailActions get actions => BookDetailActions(
    context: context,
    slug: widget.slug,
    bookDetails: bookDetails!,
    controller: controller!,
    loans: loans!,
    transactions: transactions!,
    onSignedIn: _onSignedIn,
  );

  void _onSignedIn() {
    controller?.dispose();
    _createController();
    setState(() {});
  }
}
