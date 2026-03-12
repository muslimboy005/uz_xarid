part of 'my_ads_bloc.dart';

class MyAdsState extends Equatable {
  const MyAdsState({
    this.list = const [],
    this.loading = false,
    this.error,
    this.status = 'active',
    this.deletingSlug,
  });

  final List<MyListingItemDto> list;
  final bool loading;
  final String? error;
  final String status;
  /// O'chirilayotgan e'lon slug'i — shu kartochkada o'chirish tugmasida CircularProgressIndicator ko'rsatiladi.
  final String? deletingSlug;

  MyAdsState copyWith({
    List<MyListingItemDto>? list,
    bool? loading,
    String? error,
    String? status,
    String? deletingSlug,
  }) {
    return MyAdsState(
      list: list ?? this.list,
      loading: loading ?? this.loading,
      error: error,
      status: status ?? this.status,
      deletingSlug: deletingSlug,
    );
  }

  @override
  List<Object?> get props => [list, loading, error, status, deletingSlug];
}
