import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/domain/repositories/favorites_repository.dart';

class GetFavoritesList {
  GetFavoritesList(this._repository);

  final FavoritesRepository _repository;

  Future<Either<Failure, List<FavoriteItemEntity>>> call({
    int page = 1,
    int pageSize = 8,
  }) => _repository.getList(page: page, pageSize: pageSize);
}
