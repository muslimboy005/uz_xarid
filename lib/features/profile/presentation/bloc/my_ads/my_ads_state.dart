part of 'my_ads_bloc.dart';

class MyAdsState extends Equatable {
  const MyAdsState({
    this.list = const [],
    this.loading = false,
    this.error,
    this.status = 'active',
  });

  final List<MyListingItemDto> list;
  final bool loading;
  final String? error;
  final String status;

  MyAdsState copyWith({
    List<MyListingItemDto>? list,
    bool? loading,
    String? error,
    String? status,
  }) {
    return MyAdsState(
      list: list ?? this.list,
      loading: loading ?? this.loading,
      error: error,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [list, loading, error, status];
}
