import 'package:dio/dio.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uzxarid/features/product_list/domain/entities/product_list_result.dart';
import 'package:uzxarid/features/product_list/domain/repositories/product_list_repository.dart';

class ProductListRepositoryImpl implements ProductListRepository {
  ProductListRepositoryImpl(this._remoteDatasource);

  final ProductListRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, ProductListResult>> getProducts({
    String? searchQuery,
    int? categoryId,
    String listSource = 'recommendations',
    int page = 1,
    int pageSize = 100,
    String adType = 'Sell',
    String? categoryType,
    Map<String, dynamic>? filterParams,
    String? sort,
  }) async {
    try {
      final hasFilters = filterParams != null && filterParams.isNotEmpty;

      final dtos = searchQuery != null && searchQuery.trim().isNotEmpty
          ? await _remoteDatasource.getSearchResults(
              query: searchQuery.trim(),
              page: page,
              pageSize: pageSize,
              filterParams: filterParams,
            )
          // categoryId bo'lsa o'sha turkum; categoryId null bo'lsa-yu
          // listSource == 'category' bo'lsa (bosh ekrandagi asosiy
          // kategoriya tanlangan holat) — turkum turi (listing_type)
          // bo'yicha /ad/ endpointidan e'lon olamiz, tavsiyalar
          // (/ad/recommendations/) emas.
          : categoryId != null || listSource == 'category'
          ? await _remoteDatasource.getByCategory(
              categoryId: categoryId,
              page: page,
              pageSize: pageSize,
              adType: adType,
              listingType: categoryType,
              filterParams: filterParams,
            )
          // When filters are active, always route through the /ad/ endpoint
          // so price_min, price_max, color, etc. are actually applied.
          : hasFilters
          ? await _remoteDatasource.getFiltered(
              filterParams: filterParams,
              page: page,
              pageSize: pageSize,
              adType: adType,
              listingType: categoryType,
            )
          : listSource == 'services'
          ? await _remoteDatasource.getServices(page: page, pageSize: pageSize)
          : listSource == 'gifts'
          ? await _remoteDatasource.getGifts(page: page, pageSize: pageSize)
          : await _remoteDatasource.getRecommendations(
              page: page,
              pageSize: pageSize,
              adType: adType,
              sort: sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking'
            );
      final list = dtos.map((dto) => dto.toEntity()).toList();
      // To'liq sahifa qaytdi — ehtimol yana sahifa bor. Kam qaytsa — oxiri.
      final hasMore = dtos.length >= pageSize;
      return Right(ProductListResult(items: list, hasMore: hasMore));
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
