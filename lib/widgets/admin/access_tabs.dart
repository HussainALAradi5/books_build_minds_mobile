import 'package:flutter/material.dart';

import '../shared/paged_records.dart';
import '../../services/admin/admin_service.dart';
import '../../models/admin/access_record.dart';

class AccessTabs extends StatelessWidget {
  const AccessTabs({super.key, required this.service});

  final AdminService service;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Column(
      children: [
        const TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: 'Permissions'),
            Tab(text: 'Roles'),
            Tab(text: 'Groups'),
            Tab(text: 'Users'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              for (final resource in [
                'permissions',
                'roles',
                'groups',
                'users',
              ])
                PagedRecords<AccessRecord>(
                  load: (page) => service.access(resource, page),
                  itemBuilder: (context, item, refresh) => Card(
                    child: ListTile(
                      leading: Icon(
                        resource == 'users'
                            ? Icons.person_outline_rounded
                            : resource == 'groups'
                            ? Icons.groups_outlined
                            : resource == 'roles'
                            ? Icons.badge_outlined
                            : Icons.key_outlined,
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.detail),
                      trailing: item.isSystem
                          ? const Icon(Icons.verified_user_outlined, size: 19)
                          : null,
                    ),
                  ),
                  emptyTitle: 'Nothing to show',
                  emptyMessage: 'No $resource are available.',
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
