import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/favorites/data/datasources/favorites_api.dart';
import 'package:uz_xarid/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required FavoritesApi api,
    required FavoritesLocalDatasource localDatasource,
    required SecureStorageService secureStorage,
  }) : _api = api,
       _local = localDatasource,
       _secure = secureStorage;

  final FavoritesApi _api;
  final FavoritesLocalDatasource _local;
  final SecureStorageService _secure;

  Future<bool> get _isLoggedIn => _secure.hasToken();

  @override
  Future<Either<Failure, ToggleLikeResult>> toggle({
    required String adSlug,
    FavoriteItemEntity? adForLocal,
  }) async {
    final loggedIn = await _isLoggedIn;
    if (loggedIn) {
      try {
        final res = await _api.toggle({'ad_slug': adSlug});
        if (!res.status) {
          return Left(ServerFailure(message: 'Xatolik yuz berdi'));
        }
        final status = res.data?.status ?? 'unliked';
        final isLiked = status == 'liked';
        final likesCount = res.data?.likesCount;
        return Right(
          ToggleLikeResult(isLiked: isLiked, likesCount: likesCount),
        );
      } on DioException catch (e) {
        final msg = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
        return Left(ServerFailure(message: msg));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final isLiked = await _local.isLiked(adSlug);
      if (isLiked) {
        await _local.removeLiked(adSlug);
        return Right(ToggleLikeResult(isLiked: false));
      } else {
        if (adForLocal != null) {
          await _local.addLiked(adForLocal);
        } else {
          await _local.addLiked(
            FavoriteItemEntity(slug: adSlug, title: '', isLiked: true),
          );
        }
        return Right(ToggleLikeResult(isLiked: true));
      }
    }
  }

  @override
  Future<Either<Failure, List<FavoriteItemEntity>>> getList({
    int page = 1,
    int pageSize = 8,
  }) async {
    final loggedIn = await _isLoggedIn;
    if (loggedIn) {
      try {
        final res = await _api.getList(page, pageSize);
        if (!res.status) {
          return Left(ServerFailure(message: 'Ma\'lumot olib bo\'lmadi'));
        }
        final list = (res.data.results ?? [])
            .map(
              (e) => FavoriteItemEntity(
                slug: e.ad.slug,
                title: e.ad.title,
                mainImage: e.ad.mainImage,
                price: e.ad.price,
                finalPrice: e.ad.finalPrice,
                currency: e.ad.currency ?? 'uzs',
                rating: e.ad.rating ?? 0,
                reviewCount: e.ad.reviewCount ?? 0,
                isLiked: true,
              ),
            )
            .toList();
        return Right(list);
      } on DioException catch (e) {
        final msg = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
        return Left(ServerFailure(message: msg));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final list = await _local.getLikedList();
        return Right(list);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }
  }
}
