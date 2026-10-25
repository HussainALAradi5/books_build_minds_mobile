import 'package:flutter/material.dart';

import '../../dtos/admin/create_book_request.dart';
import '../../enums/catalog/book_condition.dart';
import '../../services/admin/admin_service.dart';

class BookCreateDialog extends StatefulWidget {
  const BookCreateDialog({super.key, required this.service});
  final AdminService service;

  @override
  State<BookCreateDialog> createState() => _BookCreateDialogState();
}

class _BookCreateDialogState extends State<BookCreateDialog> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final isbn = TextEditingController();
  final author = TextEditingController();
  final publisher = TextEditingController();
  final published = TextEditingController();
  final price = TextEditingController();
  final copies = TextEditingController(text: '1');
  BookCondition condition = BookCondition.good;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    for (final field in [
      title,
      description,
      isbn,
      author,
      publisher,
      published,
      price,
      copies,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add a book'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(title, 'Title'),
              _field(description, 'Description', lines: 3),
              _field(author, 'Author'),
              _field(publisher, 'Publisher'),
              _field(isbn, 'ISBN'),
              TextFormField(
                controller: published,
                readOnly: true,
                validator: _required,
                onTap: _chooseDate,
                decoration: const InputDecoration(
                  labelText: 'Publication date',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
              TextFormField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => (double.tryParse(value ?? '') ?? 0) > 0
                    ? null
                    : 'Enter a positive price',
                decoration: const InputDecoration(labelText: 'Price in BHD'),
              ),
              TextFormField(
                controller: copies,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final count = int.tryParse(value ?? '');
                  return count != null && count >= 1 && count <= 1000
                      ? null
                      : 'Enter 1 to 1000 copies';
                },
                decoration: const InputDecoration(labelText: 'Copies'),
              ),
              DropdownButtonFormField<BookCondition>(
                initialValue: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: [
                  for (final item in BookCondition.values)
                    DropdownMenuItem(value: item, child: Text(item.label)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => condition = value);
                },
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: busy ? null : _submit,
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Add book'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: lines,
    validator: _required,
    decoration: InputDecoration(labelText: label),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1400),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      published.text =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final id = await widget.service.createBook(
        CreateBookRequest(
          title: title.text,
          description: description.text,
          isbn: isbn.text,
          author: author.text,
          publisher: publisher.text,
          publishedAt: published.text,
          price: double.parse(price.text),
          copiesTotal: int.parse(copies.text),
          condition: condition,
        ),
      );
      if (mounted) Navigator.pop(context, id);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
