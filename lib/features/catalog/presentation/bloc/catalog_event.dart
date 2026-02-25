part of 'catalog_bloc.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogLoadRequested extends CatalogEvent {
  const CatalogLoadRequested({
    this.categoryType = 'Product',
    this.openCategoryId,
  });

  final String categoryType;
  /// Agar berilsa, yuklanganidan keyin shu id li turkum ochiladi (stack ga qo‘yiladi).
  final int? openCategoryId;

  @override
  List<Object?> get props => [categoryType, openCategoryId];
}

class CatalogCategorySelected extends CatalogEvent {
  const CatalogCategorySelected(this.category);

  final CategoryEntity category;

  @override
  List<Object?> get props => [category];
}

class CatalogBackPressed extends CatalogEvent {
  const CatalogBackPressed();
}

/// Path bo‘lagi bosilganda: shu indeksgacha stack ni qoldiradi (o‘sha darajada ko‘rsatadi).
class CatalogPathSegmentTapped extends CatalogEvent {
  const CatalogPathSegmentTapped(this.segmentIndex);

  final int segmentIndex;

  @override
  List<Object?> get props => [segmentIndex];
}

