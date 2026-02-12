part of 'home_category_bloc.dart';

enum HomeCategoryStatus { initial, loading, success, failure }

class HomeCategoryState extends Equatable {
  const HomeCategoryState({
    required this.selectedIndex,
    this.status = HomeCategoryStatus.initial,
    this.categories = const [],
    this.error,
  });

  final int selectedIndex;
  final HomeCategoryStatus status;
  final List<CategoryEntity> categories;
  final String? error;

  HomeCategoryState copyWith({
    int? selectedIndex,
    HomeCategoryStatus? status,
    List<CategoryEntity>? categories,
    String? error,
  }) {
    return HomeCategoryState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      error: error,
    );
  }

  @override
  List<Object?> get props => [selectedIndex, status, categories, error];
}
