part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeRequested extends HomeEvent {
  const HomeRequested({
    this.categoryType = 'Product',
    this.pageSize = 16,
    this.adType = 'Sell',
  });

  final String categoryType;
  final int pageSize;
  final String adType;

  @override
  List<Object?> get props => [categoryType, pageSize, adType];
}

class HomeCategorySelected extends HomeEvent {
  const HomeCategorySelected(this.index, this.categoryType);

  final int index;
  final String categoryType;

  @override
  List<Object?> get props => [index, categoryType];
}
