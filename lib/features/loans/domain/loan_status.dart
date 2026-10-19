import 'package:flutter/material.dart';

enum LoanStatus { active, returned, overdue }

extension LoanStatusView on LoanStatus {
  String get label => switch (this) {
    LoanStatus.active => 'Active',
    LoanStatus.returned => 'Returned',
    LoanStatus.overdue => 'Overdue',
  };

  Color get color => switch (this) {
    LoanStatus.active => const Color(0xFF3669A2),
    LoanStatus.returned => const Color(0xFF2D8060),
    LoanStatus.overdue => const Color(0xFFB84B45),
  };

  static LoanStatus? parse(String value) {
    for (final status in LoanStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }
}
