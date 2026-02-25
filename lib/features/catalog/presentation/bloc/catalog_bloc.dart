import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._getCategories, GetCategoriesParams getCategoriesParams)
      : super(const CatalogState()) {
    on<CatalogLoadRequested>(_onLoadRequested);
    on<CatalogCategorySelected>(_onCategorySelected);
    on<CatalogBackPressed>(_onBackPressed);
    on<CatalogPathSegmentTapped>(_onPathSegmentTapped);
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
      final roots = result.right;
      List<CategoryEntity>? stack;
      if (event.openCategoryId != null) {
        stack = _findPathToCategory(roots, event.openCategoryId!);
      }
      emit(state.copyWith(
        status: CatalogStatus.success,
        rootCategories: roots,
        stack: stack ?? [],
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
    if (!category.hasChildren) return;
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

  void _onPathSegmentTapped(
    CatalogPathSegmentTapped event,
    Emitter<CatalogState> emit,
  ) {
    final i = event.segmentIndex;
    if (i <= 0) {
      emit(state.copyWith(stack: []));
      return;
    }
    if (i <= state.stack.length) {
      emit(state.copyWith(stack: state.stack.sublist(0, i)));
    }
  }

  /// Berilgan id li turkumga yo‘l (stack) ni topadi. Topilmasa null.
  static List<CategoryEntity>? _findPathToCategory(
    List<CategoryEntity> roots,
    int categoryId,
  ) {
    for (final root in roots) {
      if (root.id == categoryId) return [root];
      final inChild = _findPathToCategory(root.children, categoryId);
      if (inChild != null) return [root, ...inChild];
    }
    return null;
  }
}
