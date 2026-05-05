part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesLoadListRequested extends FavoritesEvent {
  const FavoritesLoadListRequested({this.page = 1, this.pageSize = 8});
  final int page;
  final int pageSize;
  @override
  List<Object?> get props => [page, pageSize];
}

class FavoritesToggleRequested extends FavoritesEvent {
  const FavoritesToggleRequested({required this.adSlug, this.adForLocal});
  final String adSlug;
  final FavoriteItemEntity? adForLocal;
  @override
  List<Object?> get props => [adSlug, adForLocal];
}
