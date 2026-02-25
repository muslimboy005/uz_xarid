part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailLoadRequested extends ProductDetailEvent {
  const ProductDetailLoadRequested(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}
