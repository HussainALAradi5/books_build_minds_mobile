enum SortDirection { asc, desc }

extension SortDirectionView on SortDirection {
  String get label => this == SortDirection.asc ? 'Ascending' : 'Descending';
}
