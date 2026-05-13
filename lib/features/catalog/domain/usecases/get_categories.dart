import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uzxarid/features/catalog/domain/repositories/catalog_repository.dart';

class GetCategories
    extends
        UseCase<Either<Failure, List<CategoryEntity>>, GetCategoriesParams> {
  GetCategories(this.repository);

  final CatalogRepository repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
    GetCategoriesParams params,
  ) {
    return repository.getCategories(categoryType: params.categoryType);
  }
}

class GetCategoriesParams {
  const GetCategoriesParams({this.categoryType = 'Product'});

  final String categoryType;
}
