import 'package:flutter/material.dart';

import '../../dtos/admin/create_book_request.dart';
import '../../enums/catalog/book_condition.dart';
import '../../services/admin/admin_service.dart';
import '../shared/responsive_form_dialog.dart';
import '../shared/responsive_field_row.dart';
import '../shared/numeric_form_field.dart';
import '../shared/status_badge.dart';

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
  Widget build(BuildContext context) => ResponsiveFormDialog(
    title: 'Add a book',
    busy: busy,
    content: SizedBox(
      width: 420,
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(title, 'Title'),
            const SizedBox(height: 12),
            _field(description, 'Description', lines: 3),
            const SizedBox(height: 12),
            ResponsiveFieldRow(
              first: _field(author, 'Author'),
              second: _field(publisher, 'Publisher'),
            ),
            const SizedBox(height: 12),
            _field(isbn, 'ISBN'),
            const SizedBox(height: 12),
            ResponsiveFieldRow(
              first: TextFormField(
                controller: published,
                readOnly: true,
                validator: _required,
                onTap: _chooseDate,
                decoration: const InputDecoration(
                  labelText: 'Published',
                  isDense: true,
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                  suffixIconConstraints: BoxConstraints(minWidth: 28),
                ),
              ),
              second: NumericFormField(
                controller: price,
                label: 'Price · BHD',
                minimum: .001,
                errorText: 'Enter a positive price',
              ),
            ),
            const SizedBox(height: 12),
            ResponsiveFieldRow(
              minimumWidth: 250,
              first: NumericFormField(
                controller: copies,
                label: 'Copies',
                integer: true,
                minimum: 1,
                maximum: 1000,
                errorText: 'Enter 1 to 1000 copies',
              ),
              second: DropdownButtonFormField<BookCondition>(
                initialValue: condition,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  isDense: true,
                ),
                items: [
                  for (final item in BookCondition.values)
                    DropdownMenuItem(
                      value: item,
                      child: StatusBadge(label: item.label, color: item.color),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => condition = value);
                },
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
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
    minLines: 1,
    maxLines: lines,
    validator: _required,
    decoration: InputDecoration(labelText: label, isDense: true),
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
