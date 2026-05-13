import 'package:dio/dio.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uzxarid/features/catalog/data/datasources/category_children_api.dart';
import 'package:uzxarid/features/catalog/data/models/category_children_page_dto.dart';
import 'package:uzxarid/features/catalog/domain/entities/catalog_ad_item_entity.dart';
import 'package:uzxarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uzxarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uzxarid/features/home/data/datasources/home_api.dart';
import 'package:uzxarid/features/home/data/models/category_dto.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required this.homeApi,
    required this.catalogApi,
    required this.categoryChildrenApi,
    required this.dio,
  });

  final HomeApi homeApi;
  final CatalogApi catalogApi;
  final CategoryChildrenApi categoryChildrenApi;
  final Dio dio;

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

  CategoryEntity _mapChildV2ToEntity(CategoryChildV2Dto dto) {
    return CategoryEntity(
      id: dto.id,
      name: dto.name,
      image: dto.image,
      children: const [],
    );
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren({
    required int parentCategoryId,
    int pageSize = 12,
    int page = 1,
    String? categoryType,
  }) async {
    try {
      // v1 endpoint barcha turkumlar uchun barqaror — Auto bo'limi v2 da
      // bo'sh javob qaytargani sababli birinchi shu yo'lni sinaymiz.
      final response = await dio.get(
        ApiUrls.categories,
        queryParameters: {
          'parent': parentCategoryId,
          'category_type': ?categoryType,
          'page_size': pageSize,
          'page': page,
        },
      );
      final raw = response.data;
      if (raw is Map) {
        final data = raw['data'];
        if (data is Map) {
          final results = data['results'];
          if (results is List) {
            final list = <CategoryEntity>[];
            for (final item in results) {
              if (item is Map) {
                final m = item.cast<String, dynamic>();
                list.add(
                  CategoryEntity(
                    id: (m['id'] as num).toInt(),
                    name: (m['name'] ?? '').toString(),
                    image: ImageParser.parse(m['image']),
                    children: const [],
                  ),
                );
              }
            }
            if (list.isNotEmpty) return Right(list);
          }
        }
      }
      // Fallback: v2 children endpoint
      final v2 = await categoryChildrenApi.getCategoryChildren(
        parentCategoryId,
        pageSize: pageSize,
        page: page,
      );
      final list = v2.results.map(_mapChildV2ToEntity).toList();
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> searchCategories({
    required String query,
    String? categoryType,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '${ApiUrls.categories}search/',
        queryParameters: {'q': query, 'page_size': pageSize},
      );
      final raw = response.data;
      final list = <CategoryEntity>[];
      if (raw is Map) {
        final data = raw['data'];
        if (data is Map) {
          final results = data['results'];
          if (results is List) {
            for (final item in results) {
              if (item is! Map) continue;
              final m = item.cast<String, dynamic>();
              if (categoryType != null && m['category_type'] != categoryType) {
                continue;
              }
              list.add(
                CategoryEntity(
                  id: (m['id'] as num).toInt(),
                  name: (m['name'] ?? '').toString(),
                  image: ImageParser.parse(m['image']),
                  children: const [],
                ),
              );
            }
          }
        }
      }
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
