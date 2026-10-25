import 'package:flutter/material.dart';

class ModalHeading extends StatelessWidget {
  const ModalHeading({
    super.key,
    required this.title,
    this.onClose,
    this.canClose = true,
  });

  final String title;
  final VoidCallback? onClose;
  final bool canClose;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      IconButton(
        tooltip: 'Close $title',
        onPressed: canClose ? onClose ?? () => Navigator.pop(context) : null,
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );
}
