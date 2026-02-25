import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uz_xarid/features/product_list/domain/repositories/product_list_repository.dart';

class GetProductList
    extends UseCase<Either<Failure, List<ProductListItemEntity>>,
        GetProductListParams> {
  GetProductList(this._repository);

  final ProductListRepository _repository;

  @override
  Future<Either<Failure, List<ProductListItemEntity>>> call(
    GetProductListParams params,
  ) =>
      _repository.getProducts(
        categoryId: params.categoryId,
        listSource: params.listSource,
        pageSize: params.pageSize,
      );
}

class GetProductListParams {
  const GetProductListParams({
    this.categoryId,
    this.listSource = 'recommendations',
    this.pageSize = 100,
  });

  final int? categoryId;
  /// 'recommendations' | 'services' | 'gifts' – categoryId null bo'lganda qaysi ro'yxat.
  final String listSource;
  final int pageSize;
}
