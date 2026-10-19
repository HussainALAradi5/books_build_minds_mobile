import 'package:flutter/material.dart';

enum UserRole { visitor, client, employee, admin }

extension UserRoleView on UserRole {
  String get label => switch (this) {
    UserRole.visitor => 'Visitor',
    UserRole.client => 'Library member',
    UserRole.employee => 'Employee',
    UserRole.admin => 'Administrator',
  };

  Color get color => switch (this) {
    UserRole.visitor => const Color(0xFF697679),
    UserRole.client => const Color(0xFF2D8060),
    UserRole.employee => const Color(0xFF3669A2),
    UserRole.admin => const Color(0xFF7C56A2),
  };

  static UserRole parse(String? value) => switch (value) {
    'admin' => UserRole.admin,
    'employee' => UserRole.employee,
    'client' => UserRole.client,
    _ => UserRole.visitor,
  };
}
