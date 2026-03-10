part of 'add_listing_bloc.dart';

abstract class AddListingEvent extends Equatable {
  const AddListingEvent();

  @override
  List<Object?> get props => [];
}

class AddListingLoadColorsRequested extends AddListingEvent {
  const AddListingLoadColorsRequested();
}

class AddListingLoadSizesRequested extends AddListingEvent {
  const AddListingLoadSizesRequested();
}

class AddListingLoadCategoriesRequested extends AddListingEvent {
  const AddListingLoadCategoriesRequested({this.categoryType = 'Product'});

  final String categoryType;

  @override
  List<Object?> get props => [categoryType];
}

class AddListingCreateAdRequested extends AddListingEvent {
  const AddListingCreateAdRequested(this.params);

  final CreateAdParams params;

  @override
  List<Object?> get props => [params];
}
