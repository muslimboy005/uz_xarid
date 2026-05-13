import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:uzxarid/features/favorites/domain/usecases/get_favorites_list.dart';
import 'package:uzxarid/features/favorites/domain/usecases/toggle_favorite.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(this._getList, this._toggle) : super(const FavoritesState()) {
    on<FavoritesLoadListRequested>(_onLoadList);
    on<FavoritesToggleRequested>(_onToggle);
  }

  final GetFavoritesList _getList;
  final ToggleFavorite _toggle;

  Future<void> _onLoadList(
    FavoritesLoadListRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading, error: null));
    final result = await _getList(page: event.page, pageSize: event.pageSize);
    if (result is Right<Failure, List<FavoriteItemEntity>>) {
      final list = result.right;
      final slugs = list.map((e) => e.slug).toSet();
      emit(
        state.copyWith(
          list: list,
          likedSlugs: slugs,
          status: FavoritesStatus.success,
          error: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          error:
              (result as Left<Failure, List<FavoriteItemEntity>>).left.message,
        ),
      );
    }
  }

  Future<void> _onToggle(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _toggle(
      adSlug: event.adSlug,
      adForLocal: event.adForLocal,
    );
    if (result is Right<Failure, ToggleLikeResult>) {
      final res = result.right;
      final newSlugs = Set<String>.from(state.likedSlugs);
      if (res.isLiked) {
        newSlugs.add(event.adSlug);
        if (event.adForLocal != null) {
          final newList = List<FavoriteItemEntity>.from(state.list);
          if (!newList.any((e) => e.slug == event.adSlug)) {
            newList.add(event.adForLocal!);
          }
          emit(state.copyWith(likedSlugs: newSlugs, list: newList));
          return;
        }
      } else {
        newSlugs.remove(event.adSlug);
        final newList = state.list
            .where((e) => e.slug != event.adSlug)
            .toList();
        emit(state.copyWith(likedSlugs: newSlugs, list: newList));
        return;
      }
      emit(state.copyWith(likedSlugs: newSlugs));
    }
  }
}
