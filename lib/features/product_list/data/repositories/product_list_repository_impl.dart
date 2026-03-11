import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uz_xarid/features/product_list/domain/repositories/product_list_repository.dart';

class ProductListRepositoryImpl implements ProductListRepository {
  ProductListRepositoryImpl(this._remoteDatasource);

  final ProductListRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, List<ProductListItemEntity>>> getProducts({
    String? searchQuery,
    int? categoryId,
    String listSource = 'recommendations',
    int pageSize = 100,
    String adType = 'Sell',
    Map<String, dynamic>? filterParams,
    String? sort,
  }) async {
    try {
      final hasFilters = filterParams != null && filterParams.isNotEmpty;

      final dtos = searchQuery != null && searchQuery.trim().isNotEmpty
          ? await _remoteDatasource.getSearchResults(
              query: searchQuery.trim(),
              pageSize: pageSize,
              filterParams: filterParams,
            )
          : categoryId != null
          ? await _remoteDatasource.getByCategory(
              categoryId: categoryId,
              filterParams: filterParams,
            )
          // When filters are active, always route through the /ad/ endpoint
          // so price_min, price_max, color, etc. are actually applied.
          : hasFilters
          ? await _remoteDatasource.getFiltered(
              filterParams: filterParams,
              pageSize: pageSize,
              adType: adType,
            )
          : listSource == 'services'
          ? await _remoteDatasource.getServices(pageSize: pageSize)
          : listSource == 'gifts'
          ? await _remoteDatasource.getGifts(pageSize: pageSize)
          : await _remoteDatasource.getRecommendations(
              pageSize: pageSize,
              adType: adType,
              sort: sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking'
            );
      final list = dtos.map((dto) => dto.toEntity()).toList();
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
