import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_colors.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_sizes.dart';

part 'add_listing_event.dart';
part 'add_listing_state.dart';

class AddListingBloc extends Bloc<AddListingEvent, AddListingState> {
  AddListingBloc(this._getColors, this._getSizes) : super(const AddListingState()) {
    on<AddListingLoadColorsRequested>(_onLoadColorsRequested);
    on<AddListingLoadSizesRequested>(_onLoadSizesRequested);
  }

  final GetColors _getColors;
  final GetSizes _getSizes;

  Future<void> _onLoadColorsRequested(
    AddListingLoadColorsRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(colorsLoading: true, colorsError: null));
    final result = await _getColors(const GetColorsParams());
    result.either(
      (failure) => emit(state.copyWith(
        colorsLoading: false,
        colorsError: failure.message ?? 'Tarmoq xatosi',
      )),
      (list) => emit(state.copyWith(
        colorsLoading: false,
        colors: list,
        colorsError: null,
      )),
    );
  }

  Future<void> _onLoadSizesRequested(
    AddListingLoadSizesRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(sizesLoading: true, sizesError: null));
    final result = await _getSizes(const GetSizesParams());
    result.either(
      (failure) => emit(state.copyWith(
        sizesLoading: false,
        sizesError: failure.message ?? 'Tarmoq xatosi',
      )),
      (list) => emit(state.copyWith(
        sizesLoading: false,
        sizes: list,
        sizesError: null,
      )),
    );
  }
}
