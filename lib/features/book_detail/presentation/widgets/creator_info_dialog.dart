import 'package:flutter/material.dart';

import '../../domain/creator_profile.dart';

class CreatorInfoDialog extends StatelessWidget {
  const CreatorInfoDialog({
    super.key,
    required this.title,
    required this.creator,
  });

  final String title;
  final CreatorProfile creator;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.auto_stories_outlined),
    title: Text(creator.name),
    content: SizedBox(
      width: 360,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              creator.description.isEmpty
                  ? 'No biography has been added yet.'
                  : creator.description,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.public_rounded, size: 18),
                const SizedBox(width: 7),
                Text(creator.country),
              ],
            ),
            if (creator.works.isNotEmpty) ...[
              const SizedBox(height: 17),
              Text(
                'Works in this library',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...creator.works
                  .take(5)
                  .map(
                    (name) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('• $name'),
                    ),
                  ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}
