import '../../enums/loans/loan_status.dart';
import '../shared/pagination_filter.dart';

class LoanFilter extends PaginationFilter {
  const LoanFilter({
    this.status,
    super.page,
    super.perPage,
    super.sortDirection,
  });

  final LoanStatus? status;

  @override
  Map<String, String> toQuery() => {
    ...super.toQuery(),
    'status': status?.name ?? 'all',
  };
}
