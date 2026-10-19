import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/review.dart';

class ReviewCard extends StatefulWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.canEdit,
    required this.canDelete,
    required this.onSave,
    required this.onDelete,
  });

  final Review review;
  final bool canEdit;
  final bool canDelete;
  final Future<void> Function(int, String, String) onSave;
  final Future<void> Function() onDelete;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool editing = false;
  bool busy = false;
  String? error;
  late final comment = TextEditingController(text: widget.review.comment);
  late final description = TextEditingController(
    text: widget.review.description,
  );
  late int rating = widget.review.rating.round().clamp(1, 5);

  @override
  void dispose() {
    comment.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final image = review.profilePictureUrl;
    final api = AppScope.of(context).api;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundImage: image == null
                      ? null
                      : NetworkImage(api.assetUri(image).toString()),
                  child: image == null
                      ? Text(
                          review.userName.isEmpty
                              ? '?'
                              : review.userName[0].toUpperCase(),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        formatDate(review.writtenTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (review.isDeleted)
                  StatusBadge(
                    label: 'Deleted',
                    color: Theme.of(context).colorScheme.error,
                  )
                else
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.orange.shade700,
                        size: 17,
                      ),
                      Text(review.rating.toStringAsFixed(1)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (editing) ...[
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
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Your comment'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'More detail (optional)',
                ),
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() => editing = false),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: busy ? null : _save,
                    child: Text(busy ? 'Saving…' : 'Save review'),
                  ),
                ],
              ),
            ] else ...[
              Text(
                review.comment,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (review.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(review.description),
                ),
              if (!review.isDeleted &&
                  (widget.canEdit || widget.canDelete)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.canEdit)
                      TextButton.icon(
                        onPressed: () => setState(() => editing = true),
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text('Edit'),
                      ),
                    if (widget.canDelete)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: _confirmDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                        ),
                        label: const Text('Delete'),
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (comment.text.trim().length < 10) {
      setState(() => error = 'Write at least 10 characters.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onSave(rating, comment.text.trim(), description.text.trim());
      if (mounted) setState(() => editing = false);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this review?'),
        content: const Text(
          'It will be hidden from readers. This action can’t be undone here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onDelete();
  }
}
