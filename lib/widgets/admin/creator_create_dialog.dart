import 'package:flutter/material.dart';

import '../../dtos/admin/catalog_profile_request.dart';
import '../../models/catalog/country.dart';
import '../../services/admin/admin_service.dart';

class CreatorCreateDialog extends StatefulWidget {
  const CreatorCreateDialog({
    super.key,
    required this.service,
    required this.kind,
  });
  final AdminService service;
  final String kind;

  @override
  State<CreatorCreateDialog> createState() => _CreatorCreateDialogState();
}

class _CreatorCreateDialogState extends State<CreatorCreateDialog> {
  final name = TextEditingController();
  final description = TextEditingController();
  late final Future<List<Country>> countries;
  String? countryCode;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    countries = widget.service.countries().then((page) => page.items);
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Add ${widget.kind == 'authors' ? 'author' : 'publisher'}'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              maxLength: 255,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            FutureBuilder<List<Country>>(
              future: countries,
              builder: (context, snapshot) => DropdownButtonFormField<String>(
                initialValue: countryCode,
                decoration: const InputDecoration(
                  labelText: 'Country (optional)',
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('None')),
                  for (final item in snapshot.data ?? <Country>[])
                    DropdownMenuItem(value: item.code, child: Text(item.name)),
                ],
                onChanged: (value) => setState(() => countryCode = value),
              ),
            ),
            TextField(
              controller: description,
              maxLines: 3,
              maxLength: 5000,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
      FilledButton(onPressed: busy ? null : _submit, child: const Text('Save')),
    ],
  );

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
      await widget.service.createProfile(
        widget.kind,
        CatalogProfileRequest(
          name: name.text,
          description: description.text,
          countryCode: countryCode?.isEmpty == true ? null : countryCode,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
