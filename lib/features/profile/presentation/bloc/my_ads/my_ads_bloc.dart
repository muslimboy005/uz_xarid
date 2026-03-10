import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uz_xarid/features/profile/domain/usecases/get_my_listings.dart';

part 'my_ads_event.dart';
part 'my_ads_state.dart';

class MyAdsBloc extends Bloc<MyAdsEvent, MyAdsState> {
  MyAdsBloc(this._getMyListings) : super(const MyAdsState()) {
    on<MyAdsLoadRequested>(_onLoadRequested);
  }

  final GetMyListings _getMyListings;

  Future<void> _onLoadRequested(
    MyAdsLoadRequested event,
    Emitter<MyAdsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, status: event.status));
    final result = await _getMyListings(event.status);
    result.either(
      (failure) => emit(state.copyWith(
        loading: false,
        error: failure.message ?? 'Xatolik',
        list: [],
      )),
      (list) => emit(state.copyWith(
        loading: false,
        list: list,
        error: null,
      )),
    );
  }
}
