part of 'add_listing_bloc.dart';

class AddListingState extends Equatable {
  const AddListingState({
    this.colors,
    this.colorsLoading = false,
    this.colorsError,
    this.sizes,
    this.sizesLoading = false,
    this.sizesError,
    this.categories,
    this.categoriesLoading = false,
    this.categoriesError,
    this.createAdLoading = false,
    this.createAdError,
    this.createAdSlug,
    this.editSlug,
    this.adDetailForEdit,
    this.loadAdForEditLoading = false,
    this.loadAdForEditError,
  });

  final List<ColorEntity>? colors;
  final bool colorsLoading;
  final String? colorsError;

  final List<SizeEntity>? sizes;
  final bool sizesLoading;
  final String? sizesError;

  final List<CategoryEntity>? categories;
  final bool categoriesLoading;
  final String? categoriesError;

  final bool createAdLoading;
  final String? createAdError;
  final String? createAdSlug;

  final String? editSlug;
  final AdDetailEntity? adDetailForEdit;
  final bool loadAdForEditLoading;
  final String? loadAdForEditError;

  bool get isEditMode => editSlug != null && editSlug!.isNotEmpty;

  AddListingState copyWith({
    List<ColorEntity>? colors,
    bool? colorsLoading,
    String? colorsError,
    List<SizeEntity>? sizes,
    bool? sizesLoading,
    String? sizesError,
    List<CategoryEntity>? categories,
    bool? categoriesLoading,
    String? categoriesError,
    bool? createAdLoading,
    String? createAdError,
    String? createAdSlug,
    String? editSlug,
    AdDetailEntity? adDetailForEdit,
    bool? loadAdForEditLoading,
    String? loadAdForEditError,
  }) {
    return AddListingState(
      colors: colors ?? this.colors,
      colorsLoading: colorsLoading ?? this.colorsLoading,
      colorsError: colorsError,
      sizes: sizes ?? this.sizes,
      sizesLoading: sizesLoading ?? this.sizesLoading,
      sizesError: sizesError,
      categories: categories ?? this.categories,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      categoriesError: categoriesError,
      createAdLoading: createAdLoading ?? this.createAdLoading,
      createAdError: createAdError,
      createAdSlug: createAdSlug,
      editSlug: editSlug ?? this.editSlug,
      adDetailForEdit: adDetailForEdit ?? this.adDetailForEdit,
      loadAdForEditLoading: loadAdForEditLoading ?? this.loadAdForEditLoading,
      loadAdForEditError: loadAdForEditError,
    );
  }

  @override
  List<Object?> get props => [
    colors,
    colorsLoading,
    colorsError,
    sizes,
    sizesLoading,
    sizesError,
    categories,
    categoriesLoading,
    categoriesError,
    createAdLoading,
    createAdError,
    createAdSlug,
    editSlug,
    adDetailForEdit,
    loadAdForEditLoading,
    loadAdForEditError,
  ];
}
