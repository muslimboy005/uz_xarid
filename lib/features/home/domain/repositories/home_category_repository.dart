import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/home/domain/entities/category_entity.dart';

abstract class HomeCategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String categoryType,
  });
}
