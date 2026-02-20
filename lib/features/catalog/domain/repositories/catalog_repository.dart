import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';

abstract class CatalogRepository {
  /// Fetches categories tree with optional [categoryType] filter.
  /// [categoryType]: Product | Service | Auto | Home
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String categoryType = 'Product',
  });
}
