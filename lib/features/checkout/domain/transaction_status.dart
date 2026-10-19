import 'package:flutter/material.dart';

enum TransactionStatus {
  pending,
  completed,
  expired,
  failed,
  refundPending,
  refunded,
}

extension TransactionStatusView on TransactionStatus {
  String get wire => name == 'refundPending' ? 'refund_pending' : name;
  String get label => name == 'refundPending'
      ? 'Refund pending'
      : '${name[0].toUpperCase()}${name.substring(1)}';

  Color get color => switch (this) {
    TransactionStatus.pending => const Color(0xFFC07831),
    TransactionStatus.completed => const Color(0xFF2D8060),
    TransactionStatus.expired => const Color(0xFF697679),
    TransactionStatus.failed => const Color(0xFFB84B45),
    TransactionStatus.refundPending => const Color(0xFFC07831),
    TransactionStatus.refunded => const Color(0xFF32817E),
  };

  static TransactionStatus? parse(String value) {
    for (final status in TransactionStatus.values) {
      if (status.wire == value) return status;
    }
    return null;
  }
}
