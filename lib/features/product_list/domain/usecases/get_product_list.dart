import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/product_list/domain/entities/product_list_result.dart';
import 'package:uzxarid/features/product_list/domain/repositories/product_list_repository.dart';

class GetProductList
    extends UseCase<Either<Failure, ProductListResult>, GetProductListParams> {
  GetProductList(this._repository);

  final ProductListRepository _repository;

  @override
  Future<Either<Failure, ProductListResult>> call(
    GetProductListParams params,
  ) => _repository.getProducts(
    searchQuery: params.searchQuery,
    categoryId: params.categoryId,
    listSource: params.listSource,
    page: params.page,
    pageSize: params.pageSize,
    adType: params.adType,
    categoryType: params.categoryType,
    filterParams: params.filterParams,
    sort: params.sort,
  );
}

class GetProductListParams {
  const GetProductListParams({
    this.searchQuery,
    this.categoryId,
    this.listSource = 'recommendations',
    this.page = 1,
    this.pageSize = 100,
    this.adType = 'Sell',
    this.categoryType,
    this.filterParams,
    this.sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking' | null
  });

  /// Qidiruv so'rovi – berilsa ads/search API chaqiladi.
  final String? searchQuery;
  final int? categoryId;

  /// 'recommendations' | 'services' | 'gifts' – categoryId null bo'lganda qaysi ro'yxat.
  final String listSource;

  /// 1 dan boshlanadigan sahifa raqami (infinite scroll uchun).
  final int page;
  final int pageSize;
  final String adType;
  final String? categoryType;
  final Map<String, dynamic>? filterParams;
  final String? sort;
}
