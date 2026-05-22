part of 'my_ads_bloc.dart';


class MyAdsState extends Equatable {
  const MyAdsState({
    this.list = const [],
    this.loading = false,
    this.error,
    this.status = 'active',
    this.deletingSlug,
    this.limitInfo,
    this.limitLoading = false,
  });

  final List<MyListingItemDto> list;
  final bool loading;
  final String? error;
  final String status;

  /// O'chirilayotgan e'lon slug'i — shu kartochkada o'chirish tugmasida CircularProgressIndicator ko'rsatiladi.
  final String? deletingSlug;

  /// E'lonlar limiti haqida ma'lumot (GET ad/limit-info/).
  final AdLimitInfoDto? limitInfo;
  final bool limitLoading;

  MyAdsState copyWith({
    List<MyListingItemDto>? list,
    bool? loading,
    String? error,
    String? status,
    String? deletingSlug,
    AdLimitInfoDto? limitInfo,
    bool? limitLoading,
  }) {
    return MyAdsState(
      list: list ?? this.list,
      loading: loading ?? this.loading,
      error: error,
      status: status ?? this.status,
      deletingSlug: deletingSlug,
      limitInfo: limitInfo ?? this.limitInfo,
      limitLoading: limitLoading ?? this.limitLoading,
    );
  }

  @override
  List<Object?> get props => [
    list,
    loading,
    error,
    status,
    deletingSlug,
    limitInfo,
    limitLoading,
  ];
}
