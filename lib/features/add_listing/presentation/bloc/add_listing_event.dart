part of 'add_listing_bloc.dart';

abstract class AddListingEvent extends Equatable {
  const AddListingEvent();

  @override
  List<Object?> get props => [];
}

/// Ranglar ro'yxatini API dan yuklashni so'raydi.
class AddListingLoadColorsRequested extends AddListingEvent {
  const AddListingLoadColorsRequested();
}

/// O'lchamlar ro'yxatini API dan yuklashni so'raydi.
class AddListingLoadSizesRequested extends AddListingEvent {
  const AddListingLoadSizesRequested();
}
