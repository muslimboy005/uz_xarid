import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/home/domain/entities/banner_entity.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home_banners.dart';

part 'home_banner_state.dart';

class HomeBannerCubit extends Cubit<HomeBannerState> {
  HomeBannerCubit(this.getHomeBanners) : super(const HomeBannerState());

  final GetHomeBanners getHomeBanners;

  Future<void> fetchBanners() async {
    emit(state.copyWith(status: HomeBannerStatus.loading, error: null));

    final result = await getHomeBanners(const NoParams());

    if (result is Right<Failure, List<BannerEntity>>) {
      emit(
        state.copyWith(status: HomeBannerStatus.success, banners: result.right),
      );
    } else if (result is Left<Failure, List<BannerEntity>>) {
      emit(
        state.copyWith(
          status: HomeBannerStatus.failure,
          error: result.left.message ?? 'Xatolik',
        ),
      );
    }
  }
}
