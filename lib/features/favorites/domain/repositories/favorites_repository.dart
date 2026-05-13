import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';

/// Toggle natijasi: yangi like holati va likes_count.
class ToggleLikeResult {
  const ToggleLikeResult({required this.isLiked, this.likesCount});
  final bool isLiked;
  final int? likesCount;
}

abstract class FavoritesRepository {
  /// Like/unlike. Login bo'lsa API, bo'lmasa lokal.
  Future<Either<Failure, ToggleLikeResult>> toggle({
    required String adSlug,
    FavoriteItemEntity? adForLocal,
  });

  /// Ro'yxat. Login bo'lsa API (pagination), bo'lmasa lokal.
  Future<Either<Failure, List<FavoriteItemEntity>>> getList({
    int page = 1,
    int pageSize = 8,
  });
}
