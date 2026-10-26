enum BookSort { recent, title, mostRated, bestSelling, price }

extension BookSortView on BookSort {
  String get label => switch (this) {
    BookSort.recent => 'Date added',
    BookSort.title => 'Title',
    BookSort.mostRated => 'Most rated',
    BookSort.bestSelling => 'Best selling',
    BookSort.price => 'Price',
  };

  String get wireValue => switch (this) {
    BookSort.mostRated => 'most_rated',
    BookSort.bestSelling => 'best_selling',
    _ => name,
  };
}
