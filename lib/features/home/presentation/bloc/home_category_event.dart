part of 'home_category_bloc.dart';

abstract class HomeCategoryEvent extends Equatable {
  const HomeCategoryEvent();

  @override
  List<Object?> get props => [];
}

class HomeCategorySelected extends HomeCategoryEvent {
  const HomeCategorySelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
