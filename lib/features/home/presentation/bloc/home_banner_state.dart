part of 'home_banner_cubit.dart';

enum HomeBannerStatus { initial, loading, success, failure }

class HomeBannerState extends Equatable {
  const HomeBannerState({
    this.status = HomeBannerStatus.initial,
    this.banners = const [],
    this.error,
  });

  final HomeBannerStatus status;
  final List<BannerEntity> banners;
  final String? error;

  HomeBannerState copyWith({
    HomeBannerStatus? status,
    List<BannerEntity>? banners,
    String? error,
  }) {
    return HomeBannerState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, banners, error];
}
