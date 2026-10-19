enum BookSort { recent, title, rating, price }

extension BookSortView on BookSort {
  String get label => switch (this) {
    BookSort.recent => 'Date added',
    BookSort.title => 'Title',
    BookSort.rating => 'Reader rating',
    BookSort.price => 'Price',
  };
}
