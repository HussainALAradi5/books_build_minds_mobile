import 'package:flutter/material.dart';

enum BookCondition { newBook, good, fair, damaged }

extension BookConditionView on BookCondition {
  String get wireValue => switch (this) {
    BookCondition.newBook => 'new',
    BookCondition.good => 'good',
    BookCondition.fair => 'fair',
    BookCondition.damaged => 'damaged',
  };

  String get label => switch (this) {
    BookCondition.newBook => 'New',
    BookCondition.good => 'Good',
    BookCondition.fair => 'Fair',
    BookCondition.damaged => 'Damaged',
  };

  Color get color => switch (this) {
    BookCondition.newBook => const Color(0xFF2D8060),
    BookCondition.good => const Color(0xFF3669A2),
    BookCondition.fair => const Color(0xFFC07831),
    BookCondition.damaged => const Color(0xFFB84B45),
  };

  static BookCondition? fromWire(String? value) {
    for (final condition in BookCondition.values) {
      if (condition.wireValue == value) return condition;
    }
    return null;
  }
}
