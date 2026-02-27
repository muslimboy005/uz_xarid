import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/domain/repositories/favorites_repository.dart';

class GetFavoritesList {
  GetFavoritesList(this._repository);

  final FavoritesRepository _repository;

  Future<Either<Failure, List<FavoriteItemEntity>>> call({
    int page = 1,
    int pageSize = 8,
  }) =>
      _repository.getList(page: page, pageSize: pageSize);
}
