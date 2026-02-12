import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/home/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home_categories.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';

part 'home_category_event.dart';
part 'home_category_state.dart';

class HomeCategoryBloc extends Bloc<HomeCategoryEvent, HomeCategoryState> {
  HomeCategoryBloc(this.getCategories)
    : super(const HomeCategoryState(selectedIndex: 0)) {
    on<HomeCategoriesRequested>(_onRequested);
    on<HomeCategorySelected>(_onSelected);
  }

  final GetHomeCategories getCategories;

  Future<void> _onRequested(
    HomeCategoriesRequested event,
    Emitter<HomeCategoryState> emit,
  ) async {
    emit(state.copyWith(status: HomeCategoryStatus.loading, error: null));
    final result = await getCategories(
      CategoryParams(categoryType: event.categoryType),
    );

    if (result is Right<Failure, List<CategoryEntity>>) {
      emit(
        state.copyWith(
          status: HomeCategoryStatus.success,
          categories: result.right,
        ),
      );
    } else if (result is Left<Failure, List<CategoryEntity>>) {
      emit(
        state.copyWith(
          status: HomeCategoryStatus.failure,
          error: result.left.message ?? 'Xatolik',
        ),
      );
    }
  }

  void _onSelected(
    HomeCategorySelected event,
    Emitter<HomeCategoryState> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}
