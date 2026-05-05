import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/catalog_ad_item_entity.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';

abstract class CatalogRepository {
  /// Fetches categories tree with optional [categoryType] filter.
  /// [categoryType]: Product | Service | Auto | Home
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    String categoryType = 'Product',
  });

  /// Turkum bo‘yicha yoki barcha e'lonlar (categoryId null bo‘lsa barchasi).
  Future<Either<Failure, List<CatalogAdItemEntity>>> getAdsByCategory({
    int? categoryId,
    String adType = 'Buy',
    String listingType = 'Product',
    int page = 1,
    int pageSize = 10,
  });

  /// Berilgan turkum ostidagi podturkumlar (API v2, sahifalangan).
  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren({
    required int parentCategoryId,
    int pageSize = 12,
    int page = 1,
  });
}
