import 'package:flutter/material.dart';

import '../../models/admin/access_record.dart';
import '../../services/admin/admin_service.dart';

class AccessChoices extends StatefulWidget {
  const AccessChoices({
    super.key,
    required this.service,
    required this.resource,
    required this.selectedKeys,
    required this.selectedGroups,
    required this.onChange,
  });

  final AdminService service;
  final String resource;
  final Set<String> selectedKeys;
  final Set<int> selectedGroups;
  final VoidCallback onChange;

  @override
  State<AccessChoices> createState() => _AccessChoicesState();
}

class _AccessChoicesState extends State<AccessChoices> {
  late Future<List<AccessRecord>> keys;
  Future<List<AccessRecord>>? groups;

  @override
  void initState() {
    super.initState();
    keys = widget.service.allAccess(
      widget.resource == 'roles' ? 'permissions' : 'roles',
    );
    if (widget.resource == 'users') groups = widget.service.allAccess('groups');
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 14),
      Text(
        widget.resource == 'roles' ? 'Permissions' : 'Access roles',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      FutureBuilder<List<AccessRecord>>(
        future: keys,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Could not load choices: ${snapshot.error}');
          }
          if (!snapshot.hasData) return const LinearProgressIndicator();
          return Wrap(
            spacing: 6,
            runSpacing: 2,
            children: [
              for (final item in snapshot.data!)
                FilterChip(
                  label: Text(item.name),
                  selected: widget.selectedKeys.contains(item.key),
                  onSelected: (selected) {
                    if (selected) {
                      widget.selectedKeys.add(item.key!);
                    } else {
                      widget.selectedKeys.remove(item.key);
                    }
                    widget.onChange();
                  },
                ),
            ],
          );
        },
      ),
      if (groups != null) ...[
        const SizedBox(height: 14),
        Text('Groups', style: Theme.of(context).textTheme.titleSmall),
        FutureBuilder<List<AccessRecord>>(
          future: groups,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Could not load groups: ${snapshot.error}');
            }
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return Wrap(
              spacing: 6,
              children: [
                for (final item in snapshot.data!)
                  FilterChip(
                    label: Text(item.name),
                    selected: widget.selectedGroups.contains(item.id),
                    onSelected: (selected) {
                      if (selected) {
                        widget.selectedGroups.add(item.id!);
                      } else {
                        widget.selectedGroups.remove(item.id);
                      }
                      widget.onChange();
                    },
                  ),
              ],
            );
          },
        ),
      ],
    ],
  );
}
