import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/catalog/domain/entities/catalog_ad_item_entity.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';

class GetAdsByCategory
    extends UseCase<Either<Failure, List<CatalogAdItemEntity>>, GetAdsByCategoryParams> {
  GetAdsByCategory(this._repository);

  final CatalogRepository _repository;

  @override
  Future<Either<Failure, List<CatalogAdItemEntity>>> call(
    GetAdsByCategoryParams params,
  ) {
    return _repository.getAdsByCategory(
      categoryId: params.categoryId,
      adType: params.adType,
      listingType: params.listingType,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetAdsByCategoryParams {
  const GetAdsByCategoryParams({
    this.categoryId,
    this.adType = 'Buy',
    this.listingType = 'Product',
    this.page = 1,
    this.pageSize = 10,
  });

  final int? categoryId;
  final String adType;
  final String listingType;
  final int page;
  final int pageSize;
}
