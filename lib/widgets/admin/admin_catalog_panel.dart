import 'package:flutter/material.dart';

import '../../services/admin/admin_service.dart';
import 'book_create_dialog.dart';
import 'creator_create_dialog.dart';

class AdminCatalogPanel extends StatelessWidget {
  const AdminCatalogPanel({
    super.key,
    required this.service,
    required this.permissions,
  });
  final AdminService service;
  final Set<String> permissions;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Catalog setup', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 7),
      const Text(
        'Create records here, then manage prices, images, and stock '
        'from Inventory. Existing book details and creator profiles are fixed.',
      ),
      const SizedBox(height: 18),
      if (permissions.contains('book:write.one'))
        _action(
          context,
          Icons.add_circle_outline,
          'Add a book',
          'Title, creator, publication, price, and condition',
          () async {
            final id = await showDialog<int>(
              context: context,
              builder: (_) => BookCreateDialog(service: service),
            );
            if (context.mounted && id != null) {
              _message(context, 'Book added. Open Inventory to add images.');
            }
          },
        ),
      if (permissions.contains('author:write.one'))
        _action(
          context,
          Icons.person_add_alt_outlined,
          'Add an author',
          'Name, country, and biography',
          () => _creator(context, 'authors'),
        ),
      if (permissions.contains('publisher:write.one'))
        _action(
          context,
          Icons.apartment_outlined,
          'Add a publisher',
          'Name, country, and description',
          () => _creator(context, 'publishers'),
        ),
      if (permissions.contains('country:sync'))
        _action(
          context,
          Icons.public_outlined,
          'Sync countries',
          'Refresh the server country catalog',
          () async {
            try {
              await service.syncCountries();
              if (context.mounted) _message(context, 'Countries updated.');
            } catch (failure) {
              if (context.mounted) _message(context, '$failure');
            }
          },
        ),
    ],
  );

  Widget _action(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );

  Future<void> _creator(BuildContext context, String kind) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CreatorCreateDialog(service: service, kind: kind),
    );
    if (context.mounted && saved == true) _message(context, 'Profile added.');
  }

  void _message(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
