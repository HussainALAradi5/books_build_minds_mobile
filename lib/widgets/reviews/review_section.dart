import 'package:flutter/material.dart';

import '../../controllers/book_detail/book_detail_controller.dart';
import './review_card.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key, required this.controller});

  final BookDetailController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final book = controller.detail!.book;
    final page = controller.reviews;
    final eligible = user?.purchasedBookIds.contains(book.bookId) ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reader reviews',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Icon(Icons.star_rounded, color: Colors.orange.shade700, size: 21),
            Text(book.averageRating.toStringAsFixed(1)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          eligible
              ? 'Share what stayed with you.'
              : 'Readers who purchased this book can leave a review.',
        ),
        if (user?.isAdmin ?? false)
          SwitchListTile.adaptive(
            value: controller.includeDeleted,
            title: const Text('Show deleted reviews'),
            contentPadding: EdgeInsets.zero,
            onChanged: (value) async {
              try {
                await controller.toggleDeleted(value);
              } catch (failure) {
                if (context.mounted) _error(context, '$failure');
              }
            },
          ),
        if (eligible && controller.myReview == null) ...[
          const SizedBox(height: 16),
          _ReviewComposer(controller: controller),
        ],
        const SizedBox(height: 13),
        if (page?.items.isEmpty ?? true)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No reviews yet. The first reader story is waiting.'),
          ),
        ...?page?.items.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReviewCard(
              key: ValueKey(review.id),
              review: review,
              canEdit: user?.userId == review.userId,
              canDelete:
                  user?.userId == review.userId || (user?.isAdmin ?? false),
              onSave: (rating, comment, description) => controller.saveReview(
                rating: rating,
                comment: comment,
                description: description,
              ),
              onDelete: () async {
                try {
                  await controller.deleteReview(review);
                } catch (failure) {
                  if (context.mounted) _error(context, '$failure');
                }
              },
            ),
          ),
        ),
        if (page != null && (page.hasNext || page.hasPrevious))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                onPressed: page.hasPrevious
                    ? () => controller.loadReviews(page: page.page - 1)
                    : null,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${page.page} / ${page.pages}'),
              ),
              IconButton.outlined(
                onPressed: page.hasNext
                    ? () => controller.loadReviews(page: page.page + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
      ],
    );
  }

  void _error(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

class _ReviewComposer extends StatefulWidget {
  const _ReviewComposer({required this.controller});
  final BookDetailController controller;

  @override
  State<_ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends State<_ReviewComposer> {
  int rating = 5;
  final comment = TextEditingController();
  final description = TextEditingController();
  String? error;

  @override
  void dispose() {
    comment.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your review', style: Theme.of(context).textTheme.titleLarge),
          Wrap(
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => rating = index + 1),
                icon: Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.orange.shade700,
                ),
                tooltip: '${index + 1} stars',
              ),
            ),
          ),
          TextField(
            controller: comment,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Your comment'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: description,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'More detail (optional)',
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.controller.busy ? null : _save,
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Post review'),
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    if (comment.text.trim().length < 10) {
      setState(() => error = 'Write at least 10 characters.');
      return;
    }
    try {
      await widget.controller.saveReview(
        rating: rating,
        comment: comment.text.trim(),
        description: description.text.trim(),
      );
      if (mounted) setState(() => error = null);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    }
  }
}
