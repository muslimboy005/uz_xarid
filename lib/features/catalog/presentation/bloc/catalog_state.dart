part of 'catalog_bloc.dart';

enum CatalogStatus { initial, loading, success, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.categoryType = 'Product',
    this.rootCategories = const [],
    this.stack = const [],
    this.error,
    this.showTypeTiles = true,
  });

  final CatalogStatus status;
  final String categoryType;
  final List<CategoryEntity> rootCategories;
  /// Stack of selected categories for drill-down (breadcrumb path).
  final List<CategoryEntity> stack;
  final String? error;
  /// When true, show only 4 type tiles (Tovar va savdo, etc.). When false, show subcategories for selected type.
  final bool showTypeTiles;

  /// Current list to display: children of last in stack, or root categories.
  List<CategoryEntity> get currentList {
    if (stack.isEmpty) return rootCategories;
    return stack.last.children;
  }

  /// Breadcrumb titles for app bar (e.g. [Barcha turkumlar, Parent, Sub]).
  List<String> get breadcrumbTitles => [
    'Barcha turkumlar',
    for (final c in stack) c.displayName,
  ];

  /// Can go back: from subcategory list to type tiles, or from deeper level to parent list.
  bool get canGoBack => stack.isNotEmpty || !showTypeTiles;

  CatalogState copyWith({
    CatalogStatus? status,
    String? categoryType,
    List<CategoryEntity>? rootCategories,
    List<CategoryEntity>? stack,
    String? error,
    bool? showTypeTiles,
  }) {
    return CatalogState(
      status: status ?? this.status,
      categoryType: categoryType ?? this.categoryType,
      rootCategories: rootCategories ?? this.rootCategories,
      stack: stack ?? this.stack,
      error: error,
      showTypeTiles: showTypeTiles ?? this.showTypeTiles,
    );
  }

  @override
  List<Object?> get props => [status, categoryType, rootCategories, stack, error, showTypeTiles];
}
