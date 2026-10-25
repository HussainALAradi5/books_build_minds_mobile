import 'package:flutter/material.dart';

import '../shared/paged_records.dart';
import '../../services/admin/admin_service.dart';
import '../../models/admin/access_record.dart';
import 'access_editor_dialog.dart';
import '../shared/confirm_action.dart';

class AccessTabs extends StatefulWidget {
  const AccessTabs({super.key, required this.service, required this.canEdit});

  final AdminService service;
  final bool canEdit;

  @override
  State<AccessTabs> createState() => _AccessTabsState();
}

class _AccessTabsState extends State<AccessTabs> {
  int revision = 0;

  Future<void> edit(
    BuildContext context,
    String resource,
    AccessRecord? item,
    VoidCallback refresh,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AccessEditorDialog(
        service: widget.service,
        resource: resource,
        record: item,
      ),
    );
    if (saved == true && mounted) {
      refresh();
      setState(() => revision++);
    }
  }

  Future<void> remove(
    BuildContext context,
    String resource,
    AccessRecord item,
    VoidCallback refresh,
  ) async {
    if (!await confirmAction(
      context,
      title: 'Delete ${item.name}?',
      message:
          'This ${resource.substring(0, resource.length - 1)} will be archived.',
      confirmLabel: 'Delete',
      destructive: true,
    )) {
      return;
    }
    try {
      await widget.service.deleteAccess(resource, item.key ?? '${item.id}');
      refresh();
    } catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$failure')));
      }
    }
  }

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
                Column(
                  children: [
                    if (widget.canEdit && resource != 'users')
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: FilledButton.icon(
                            onPressed: () =>
                                edit(context, resource, null, () {}),
                            icon: const Icon(Icons.add),
                            label: Text(
                              'Add ${resource.substring(0, resource.length - 1)}',
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: PagedRecords<AccessRecord>(
                        key: ValueKey('$resource-$revision'),
                        load: (page) => widget.service.access(resource, page),
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
                            trailing: widget.canEdit
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit ${item.name}',
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => edit(
                                          context,
                                          resource,
                                          item,
                                          refresh,
                                        ),
                                      ),
                                      if (!item.isSystem && resource != 'users')
                                        IconButton(
                                          tooltip: 'Delete ${item.name}',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          onPressed: () => remove(
                                            context,
                                            resource,
                                            item,
                                            refresh,
                                          ),
                                        ),
                                    ],
                                  )
                                : item.isSystem
                                ? const Icon(
                                    Icons.verified_user_outlined,
                                    size: 19,
                                  )
                                : null,
                          ),
                        ),
                        emptyTitle: 'Nothing to show',
                        emptyMessage: 'No $resource are available.',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
