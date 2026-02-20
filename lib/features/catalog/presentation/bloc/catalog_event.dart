part of 'catalog_bloc.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogLoadRequested extends CatalogEvent {
  const CatalogLoadRequested({this.categoryType = 'Product'});

  final String categoryType;

  @override
  List<Object?> get props => [categoryType];
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
