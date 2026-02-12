import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/home/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/home/domain/repositories/home_category_repository.dart';

class GetHomeCategories
    extends UseCase<Either<Failure, List<CategoryEntity>>, CategoryParams> {
  GetHomeCategories(this.repository);

  final HomeCategoryRepository repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(CategoryParams params) {
    return repository.getCategories(categoryType: params.categoryType);
  }
}

class CategoryParams {
  final String categoryType;

  const CategoryParams({this.categoryType = 'Product'});
}
