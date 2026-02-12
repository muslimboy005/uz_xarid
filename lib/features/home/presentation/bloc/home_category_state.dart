part of 'home_category_bloc.dart';

class HomeCategoryState extends Equatable {
  const HomeCategoryState({required this.selectedIndex});

  final int selectedIndex;

  HomeCategoryState copyWith({int? selectedIndex}) {
    return HomeCategoryState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [selectedIndex];
}
