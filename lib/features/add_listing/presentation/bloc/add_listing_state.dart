part of 'add_listing_bloc.dart';

class AddListingState extends Equatable {
  const AddListingState({
    this.colors,
    this.colorsLoading = false,
    this.colorsError,
    this.sizes,
    this.sizesLoading = false,
    this.sizesError,
  });

  final List<ColorEntity>? colors;
  final bool colorsLoading;
  final String? colorsError;

  final List<SizeEntity>? sizes;
  final bool sizesLoading;
  final String? sizesError;

  AddListingState copyWith({
    List<ColorEntity>? colors,
    bool? colorsLoading,
    String? colorsError,
    List<SizeEntity>? sizes,
    bool? sizesLoading,
    String? sizesError,
  }) {
    return AddListingState(
      colors: colors ?? this.colors,
      colorsLoading: colorsLoading ?? this.colorsLoading,
      colorsError: colorsError,
      sizes: sizes ?? this.sizes,
      sizesLoading: sizesLoading ?? this.sizesLoading,
      sizesError: sizesError,
    );
  }

  @override
  List<Object?> get props =>
      [colors, colorsLoading, colorsError, sizes, sizesLoading, sizesError];
}
