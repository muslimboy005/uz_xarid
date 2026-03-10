import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_colors.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_sizes.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/create_ad.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';

part 'add_listing_event.dart';
part 'add_listing_state.dart';

class AddListingBloc extends Bloc<AddListingEvent, AddListingState> {
  AddListingBloc(
    this._getColors,
    this._getSizes,
    this._getCategories,
    this._createAd,
  ) : super(const AddListingState()) {
    on<AddListingLoadColorsRequested>(_onLoadColorsRequested);
    on<AddListingLoadSizesRequested>(_onLoadSizesRequested);
    on<AddListingLoadCategoriesRequested>(_onLoadCategoriesRequested);
    on<AddListingCreateAdRequested>(_onCreateAdRequested);
  }

  final GetColors _getColors;
  final GetSizes _getSizes;
  final GetCategories _getCategories;
  final CreateAd _createAd;

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

  Future<void> _onLoadCategoriesRequested(
    AddListingLoadCategoriesRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(categoriesLoading: true, categoriesError: null));
    final result = await _getCategories(
      GetCategoriesParams(categoryType: event.categoryType),
    );
    result.either(
      (failure) => emit(state.copyWith(
        categoriesLoading: false,
        categoriesError: failure.message ?? 'Tarmoq xatosi',
      )),
      (list) => emit(state.copyWith(
        categoriesLoading: false,
        categories: list,
        categoriesError: null,
      )),
    );
  }

  Future<void> _onCreateAdRequested(
    AddListingCreateAdRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(createAdLoading: true, createAdError: null));
    final result = await _createAd(event.params);
    result.either(
      (failure) => emit(state.copyWith(
        createAdLoading: false,
        createAdError: failure.message ?? 'Xatolik yuz berdi',
      )),
      (createResult) => emit(state.copyWith(
        createAdLoading: false,
        createAdError: null,
        createAdSlug: createResult.slug,
      )),
    );
  }
}
