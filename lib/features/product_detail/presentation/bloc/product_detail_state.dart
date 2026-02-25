part of 'product_detail_bloc.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.ad,
    this.error,
  });

  final ProductDetailStatus status;
  final AdDetailEntity? ad;
  final String? error;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    AdDetailEntity? ad,
    String? error,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      ad: ad ?? this.ad,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, ad, error];
}
