import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_ad_detail.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc(this._getAdDetail) : super(const ProductDetailState()) {
    on<ProductDetailLoadRequested>(_onLoadRequested);
  }

  final GetAdDetail _getAdDetail;

  Future<void> _onLoadRequested(
    ProductDetailLoadRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(state.copyWith(status: ProductDetailStatus.loading, error: null));
    final result = await _getAdDetail(GetAdDetailParams(slug: event.slug));
    if (result is Right<Failure, AdDetailEntity>) {
      emit(
        state.copyWith(status: ProductDetailStatus.success, ad: result.right),
      );
    } else if (result is Left<Failure, AdDetailEntity>) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          error: result.left.message ?? 'Xatolik',
        ),
      );
    }
  }
}
