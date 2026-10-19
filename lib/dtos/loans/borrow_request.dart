class BorrowRequest {
  const BorrowRequest({required this.policyVersion});

  final String policyVersion;

  Map<String, dynamic> toJson() => {
    'accepted_terms': true,
    'policy_version': policyVersion,
  };
}
