import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uz_xarid/features/product_list/domain/repositories/product_list_repository.dart';

class GetProductList
    extends
        UseCase<
          Either<Failure, List<ProductListItemEntity>>,
          GetProductListParams
        > {
  GetProductList(this._repository);

  final ProductListRepository _repository;

  @override
  Future<Either<Failure, List<ProductListItemEntity>>> call(
    GetProductListParams params,
  ) => _repository.getProducts(
    searchQuery: params.searchQuery,
    categoryId: params.categoryId,
    listSource: params.listSource,
    pageSize: params.pageSize,
    adType: params.adType,
    filterParams: params.filterParams,
    sort: params.sort,
  );
}

class GetProductListParams {
  const GetProductListParams({
    this.searchQuery,
    this.categoryId,
    this.listSource = 'recommendations',
    this.pageSize = 100,
    this.adType = 'Sell',
    this.filterParams,
    this.sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking' | null
  });

  /// Qidiruv so'rovi – berilsa ads/search API chaqiladi.
  final String? searchQuery;
  final int? categoryId;

  /// 'recommendations' | 'services' | 'gifts' – categoryId null bo'lganda qaysi ro'yxat.
  final String listSource;
  final int pageSize;
  final String adType;
  final Map<String, dynamic>? filterParams;
  final String? sort;
}
