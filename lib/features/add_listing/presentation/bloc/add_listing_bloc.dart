import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_colors.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_sizes.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/create_ad.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/update_ad.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_ad_detail.dart';

part 'add_listing_event.dart';
part 'add_listing_state.dart';

class AddListingBloc extends Bloc<AddListingEvent, AddListingState> {
  AddListingBloc(
    this._getColors,
    this._getSizes,
    this._getCategories,
    this._createAd,
    this._updateAd,
    this._getAdDetail,
  ) : super(const AddListingState()) {
    on<AddListingLoadColorsRequested>(_onLoadColorsRequested);
    on<AddListingLoadSizesRequested>(_onLoadSizesRequested);
    on<AddListingLoadCategoriesRequested>(_onLoadCategoriesRequested);
    on<AddListingLoadAdForEditRequested>(_onLoadAdForEditRequested);
    on<AddListingCreateAdRequested>(_onCreateAdRequested);
    on<AddListingUpdateAdRequested>(_onUpdateAdRequested);
  }

  final GetColors _getColors;
  final GetSizes _getSizes;
  final GetCategories _getCategories;
  final CreateAd _createAd;
  final UpdateAd _updateAd;
  final GetAdDetail _getAdDetail;

  Future<void> _onLoadColorsRequested(
    AddListingLoadColorsRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(colorsLoading: true, colorsError: null));
    final result = await _getColors(const GetColorsParams());
    result.either(
      (failure) => emit(
        state.copyWith(
          colorsLoading: false,
          colorsError: failure.message ?? 'Tarmoq xatosi',
        ),
      ),
      (list) => emit(
        state.copyWith(colorsLoading: false, colors: list, colorsError: null),
      ),
    );
  }

  Future<void> _onLoadSizesRequested(
    AddListingLoadSizesRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(sizesLoading: true, sizesError: null));
    final result = await _getSizes(const GetSizesParams());
    result.either(
      (failure) => emit(
        state.copyWith(
          sizesLoading: false,
          sizesError: failure.message ?? 'Tarmoq xatosi',
        ),
      ),
      (list) => emit(
        state.copyWith(sizesLoading: false, sizes: list, sizesError: null),
      ),
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
      (failure) => emit(
        state.copyWith(
          categoriesLoading: false,
          categoriesError: failure.message ?? 'Tarmoq xatosi',
        ),
      ),
      (list) => emit(
        state.copyWith(
          categoriesLoading: false,
          categories: list,
          categoriesError: null,
        ),
      ),
    );
  }

  Future<void> _onLoadAdForEditRequested(
    AddListingLoadAdForEditRequested event,
    Emitter<AddListingState> emit,
  ) async {
    developer.log(
      'AddListingBloc: LoadAdForEdit requested slug=${event.slug}',
      name: 'AddListingBloc',
    );
    emit(
      state.copyWith(
        editSlug: event.slug,
        loadAdForEditLoading: true,
        loadAdForEditError: null,
        adDetailForEdit: null,
      ),
    );
    final result = await _getAdDetail(GetAdDetailParams(slug: event.slug));
    result.either(
      (failure) {
        developer.log(
          'AddListingBloc: LoadAdForEdit FAILED slug=${event.slug}, error=${failure.message}',
          name: 'AddListingBloc',
        );
        emit(
          state.copyWith(
            loadAdForEditLoading: false,
            loadAdForEditError: failure.message ?? 'Ma\'lumot yuklanmadi',
          ),
        );
      },
      (detail) {
        developer.log(
          'AddListingBloc: LoadAdForEdit SUCCESS slug=${detail.slug}, title=${detail.title}, categoryId=${detail.categoryId}',
          name: 'AddListingBloc',
        );
        emit(
          state.copyWith(
            loadAdForEditLoading: false,
            loadAdForEditError: null,
            adDetailForEdit: detail,
          ),
        );
      },
    );
  }

  Future<void> _onCreateAdRequested(
    AddListingCreateAdRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(createAdLoading: true, createAdError: null));
    final result = await _createAd(event.params);
    result.either(
      (failure) => emit(
        state.copyWith(
          createAdLoading: false,
          createAdError: failure.message ?? 'Xatolik yuz berdi',
        ),
      ),
      (createResult) => emit(
        state.copyWith(
          createAdLoading: false,
          createAdError: null,
          createAdSlug: createResult.slug,
        ),
      ),
    );
  }

  Future<void> _onUpdateAdRequested(
    AddListingUpdateAdRequested event,
    Emitter<AddListingState> emit,
  ) async {
    emit(state.copyWith(createAdLoading: true, createAdError: null));
    final result = await _updateAd(
      UpdateAdParams(slug: event.slug, params: event.params),
    );
    result.either(
      (failure) => emit(
        state.copyWith(
          createAdLoading: false,
          createAdError: failure.message ?? 'Xatolik yuz berdi',
        ),
      ),
      (createResult) => emit(
        state.copyWith(
          createAdLoading: false,
          createAdError: null,
          createAdSlug: createResult.slug,
        ),
      ),
    );
  }
}
