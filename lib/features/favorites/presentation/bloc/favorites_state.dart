part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.list = const [],
    this.likedSlugs = const {},
    this.status = FavoritesStatus.initial,
    this.error,
  });

  final List<FavoriteItemEntity> list;
  final Set<String> likedSlugs;
  final FavoritesStatus status;
  final String? error;

  bool isLiked(String slug) => likedSlugs.contains(slug);

  FavoritesState copyWith({
    List<FavoriteItemEntity>? list,
    Set<String>? likedSlugs,
    FavoritesStatus? status,
    String? error,
  }) {
    return FavoritesState(
      list: list ?? this.list,
      likedSlugs: likedSlugs ?? this.likedSlugs,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [list, likedSlugs, status, error];
}
