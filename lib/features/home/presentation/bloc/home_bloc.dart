import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this.getHome) : super(const HomeState(selectedIndex: 0)) {
    on<HomeRequested>(_onRequested);
    on<HomeCategorySelected>(_onCategorySelected);
  }

  final GetHome getHome;

  Future<void> _onRequested(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        error: null,
        recommendations: const [],
        gifts: const [],
        services: const [],
      ),
    );
    final result = await getHome(
      HomeParams(
        categoryType: event.categoryType,
        pageSize: event.pageSize,
        adType: event.adType,
      ),
    );

    if (result is Right<Failure, HomeEntity>) {
      final data = result.right;
      emit(
        state.copyWith(
          status: HomeStatus.success,
          categories: data.categories,
          categoryIdToChildren: data.categoryIdToChildren,
          banners: data.banners,
          recommendations: data.recommendations,
          gifts: data.gifts,
          services: data.services,
          lastAdType: event.adType,
        ),
      );
    } else if (result is Left<Failure, HomeEntity>) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          error: result.left.message ?? 'Xatolik',
        ),
      );
    }
  }

  void _onCategorySelected(
    HomeCategorySelected event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.index));
    add(
      HomeRequested(
        categoryType: event.categoryType,
        adType: state.lastAdType,
        pageSize: 16,
      ),
    );
  }
}
