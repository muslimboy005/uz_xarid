import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uz_xarid/features/catalog/domain/entities/catalog_ad_item_entity.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/home/data/models/category_dto.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({required this.homeApi, required this.catalogApi});

  final HomeApi homeApi;
  final CatalogApi catalogApi;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String categoryType = 'Product',
  }) async {
    try {
      final response = await homeApi.getCategories(categoryType);
      final list = response.data.results.map(_mapDtoToEntity).toList();
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CatalogAdItemEntity>>> getAdsByCategory({
    int? categoryId,
    String adType = 'Buy',
    String listingType = 'Product',
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await catalogApi.getAds(
        categoryId: categoryId,
        adType: adType,
        listingType: listingType,
        page: page,
        pageSize: pageSize,
      );
      final list = response.data.results
          .map(
            (dto) => CatalogAdItemEntity(
              slug: dto.slug,
              title: dto.title,
              mainImage: dto.mainImage,
              price: dto.price,
              finalPrice: dto.finalPrice,
              currency: dto.currency,
              rating: dto.rating,
              reviewCount: dto.reviewCount,
            ),
          )
          .toList();
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  CategoryEntity _mapDtoToEntity(CategoryDto dto) {
    return CategoryEntity(
      id: dto.id,
      name: dto.name,
      image: dto.image,
      children: dto.children.map(_mapDtoToEntity).toList(),
    );
  }
}
