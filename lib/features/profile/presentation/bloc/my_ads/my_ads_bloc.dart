import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uz_xarid/features/profile/domain/usecases/delete_my_ad.dart';
import 'package:uz_xarid/features/profile/domain/usecases/get_my_listings.dart';

part 'my_ads_event.dart';
part 'my_ads_state.dart';

class MyAdsBloc extends Bloc<MyAdsEvent, MyAdsState> {
  MyAdsBloc(this._getMyListings, this._deleteMyAd) : super(const MyAdsState()) {
    on<MyAdsLoadRequested>(_onLoadRequested);
    on<MyAdsDeleteRequested>(_onDeleteRequested);
  }

  final GetMyListings _getMyListings;
  final DeleteMyAd _deleteMyAd;

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

  Future<void> _onDeleteRequested(
    MyAdsDeleteRequested event,
    Emitter<MyAdsState> emit,
  ) async {
    if (event.slug.isEmpty) return;
    emit(state.copyWith(deletingSlug: event.slug));
    final result = await _deleteMyAd(event.slug);
    result.either(
      (failure) => emit(state.copyWith(deletingSlug: null)),
      (_) => emit(state.copyWith(
        deletingSlug: null,
        list: state.list.where((e) => e.slug != event.slug).toList(),
      )),
    );
  }
}
