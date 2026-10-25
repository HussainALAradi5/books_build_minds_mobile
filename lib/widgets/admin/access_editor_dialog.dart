import 'package:flutter/material.dart';

import '../../dtos/admin/group_input.dart';
import '../../dtos/admin/permission_input.dart';
import '../../dtos/admin/role_input.dart';
import '../../dtos/admin/user_access_input.dart';
import '../../models/admin/access_record.dart';
import '../../services/admin/admin_service.dart';
import 'access_choices.dart';

class AccessEditorDialog extends StatefulWidget {
  const AccessEditorDialog({
    super.key,
    required this.service,
    required this.resource,
    this.record,
  });

  final AdminService service;
  final String resource;
  final AccessRecord? record;

  @override
  State<AccessEditorDialog> createState() => _AccessEditorDialogState();
}

class _AccessEditorDialogState extends State<AccessEditorDialog> {
  final formKey = GlobalKey<FormState>();
  late final keyField = TextEditingController(text: widget.record?.key ?? '');
  late final nameField = TextEditingController(text: widget.record?.name ?? '');
  late final descriptionField = TextEditingController(
    text: widget.record?.detail ?? '',
  );
  late String role = widget.record?.role ?? 'client';
  late final selectedKeys = <String>{
    ...widget.resource == 'roles'
        ? widget.record?.permissionKeys ?? <String>[]
        : widget.resource == 'groups'
        ? widget.record?.roleKeys ?? <String>[]
        : widget.record?.accessRoleKeys ?? <String>[],
  };
  late final selectedGroups = <int>{...?widget.record?.groupIds};
  bool busy = false;
  String? error;

  @override
  void dispose() {
    keyField.dispose();
    nameField.dispose();
    descriptionField.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final item = widget.record;
      switch (widget.resource) {
        case 'permissions':
          await widget.service.savePermission(
            PermissionInput(
              key: keyField.text,
              label: nameField.text,
              description: descriptionField.text,
            ),
            item?.key,
          );
        case 'roles':
          await widget.service.saveRole(
            RoleInput(
              key: keyField.text,
              name: nameField.text,
              description: descriptionField.text,
              permissionKeys: selectedKeys.toList(),
            ),
            item?.key,
          );
        case 'groups':
          await widget.service.saveGroup(
            GroupInput(
              name: nameField.text,
              description: descriptionField.text,
              roleKeys: selectedKeys.toList(),
            ),
            item?.id,
          );
        case 'users':
          await widget.service.saveUser(
            item!.id!,
            UserAccessInput(
              role: role,
              accessRoleKeys: selectedKeys.toList(),
              groupIds: selectedGroups.toList(),
            ),
          );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    final isUser = resource == 'users';
    return AlertDialog(
      title: Text(
        '${widget.record == null ? 'Add' : 'Edit'} ${resource.substring(0, resource.length - 1)}',
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resource == 'permissions' || resource == 'roles')
                  TextFormField(
                    controller: keyField,
                    enabled: widget.record == null,
                    decoration: const InputDecoration(labelText: 'Key'),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Key is required'
                        : null,
                  ),
                if (!isUser)
                  TextFormField(
                    controller: nameField,
                    decoration: InputDecoration(
                      labelText: resource == 'permissions' ? 'Label' : 'Name',
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Name is required'
                        : null,
                  ),
                if (!isUser)
                  TextFormField(
                    controller: descriptionField,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                if (isUser)
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Account role',
                    ),
                    items: const ['visitor', 'client', 'employee', 'admin']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => role = value ?? role),
                  ),
                if (resource == 'roles' || resource == 'groups' || isUser)
                  AccessChoices(
                    service: widget.service,
                    resource: resource,
                    selectedKeys: selectedKeys,
                    selectedGroups: selectedGroups,
                    onChange: () => setState(() {}),
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
          onPressed: busy ? null : save,
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
