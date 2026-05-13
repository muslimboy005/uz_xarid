import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/domain/repositories/favorites_repository.dart';

class ToggleFavorite {
  ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<Either<Failure, ToggleLikeResult>> call({
    required String adSlug,
    FavoriteItemEntity? adForLocal,
  }) => _repository.toggle(adSlug: adSlug, adForLocal: adForLocal);
}
