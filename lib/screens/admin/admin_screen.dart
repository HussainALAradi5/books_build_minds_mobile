import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../widgets/shared/paged_records.dart';
import '../../widgets/shared/state_panel.dart';
import '../../models/catalog/book.dart';
import '../../services/admin/admin_service.dart';
import '../../widgets/admin/inventory_tile.dart';
import '../../widgets/admin/access_tabs.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).session.user;
    if (user?.isAdmin != true) {
      return const StatePanel(
        icon: Icons.lock_outline_rounded,
        title: 'Administrator only',
        message: 'This area requires administrator access.',
      );
    }
    final service = AdminService(AppScope.of(context).api);
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIBRARY MANAGEMENT',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Admin studio',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Inventory'),
              Tab(icon: Icon(Icons.shield_outlined), text: 'Access'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                user!.permissions.contains('book:read.any')
                    ? PagedRecords<Book>(
                        load: service.inventory,
                        itemBuilder: (context, book, refresh) => InventoryTile(
                          book: book,
                          service: service,
                          refresh: refresh,
                          canEdit: user.permissions.contains('book:edit.any'),
                        ),
                        emptyTitle: 'No catalog records',
                        emptyMessage:
                            'Books will appear after they are created.',
                      )
                    : const StatePanel(
                        icon: Icons.lock_outline_rounded,
                        title: 'Inventory access required',
                        message:
                            'Your role does not include inventory read access.',
                      ),
                user.permissions.contains('access:read.any')
                    ? AccessTabs(service: service)
                    : const StatePanel(
                        icon: Icons.lock_outline_rounded,
                        title: 'Access rules unavailable',
                        message: 'Your role does not include access management read permission.',
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
