import 'package:flutter/material.dart';

import '../../services/admin/admin_service.dart';
import '../shared/responsive_form_dialog.dart';

class CategoryCreateDialog extends StatefulWidget {
  const CategoryCreateDialog({super.key, required this.service});
  final AdminService service;

  @override
  State<CategoryCreateDialog> createState() => _CategoryCreateDialogState();
}

class _CategoryCreateDialogState extends State<CategoryCreateDialog> {
  final name = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = 'Name is required.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.service.createCategory(name.text);
      if (mounted) Navigator.pop(context, true);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ResponsiveFormDialog(
    title: 'Add category',
    busy: busy,
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Category name',
              counterText: '',
            ),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: busy ? null : _submit,
        child: const Text('Add category'),
      ),
    ],
  );
}
