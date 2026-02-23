import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._getCategories, GetCategoriesParams getCategoriesParams) : super(const CatalogState()) {
    on<CatalogLoadRequested>(_onLoadRequested);
    on<CatalogCategorySelected>(_onCategorySelected);
    on<CatalogBackPressed>(_onBackPressed);
  }

  final GetCategories _getCategories;

  Future<void> _onLoadRequested(
    CatalogLoadRequested event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(
      status: CatalogStatus.loading,
      categoryType: event.categoryType,
      error: null,
      stack: [],
      showTypeTiles: false,
    ));

    final result = await _getCategories(
      GetCategoriesParams(categoryType: event.categoryType),
    );

    if (result is Right<Failure, List<CategoryEntity>>) {
      emit(state.copyWith(
        status: CatalogStatus.success,
        rootCategories: result.right,
      ));
    } else if (result is Left<Failure, List<CategoryEntity>>) {
      emit(state.copyWith(
        status: CatalogStatus.failure,
        error: result.left.message ?? 'Xatolik',
      ));
    }
  }

  void _onCategorySelected(
    CatalogCategorySelected event,
    Emitter<CatalogState> emit,
  ) {
    final category = event.category;
    if (!category.hasChildren) {
      // TODO: navigate to products list for this category
      return;
    }
    emit(state.copyWith(stack: [...state.stack, category]));
  }

  void _onBackPressed(CatalogBackPressed event, Emitter<CatalogState> emit) {
    if (!state.canGoBack) return;
    if (state.stack.isNotEmpty) {
      final newStack = state.stack.sublist(0, state.stack.length - 1);
      emit(state.copyWith(stack: newStack));
    } else {
      emit(state.copyWith(showTypeTiles: true));
    }
  }
}
