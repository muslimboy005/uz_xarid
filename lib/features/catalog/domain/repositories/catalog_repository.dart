import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/catalog/domain/entities/catalog_ad_item_entity.dart';
import 'package:uzxarid/features/catalog/domain/entities/category_entity.dart';

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

  /// Berilgan turkum ostidagi podturkumlar.
  /// [categoryType] berilsa, v1 (`category/?parent=...&category_type=...`) ishlatiladi —
  /// ayrim turkumlar uchun v2 children endpoint to'liq javob qaytarmagani uchun.
  Future<Either<Failure, List<CategoryEntity>>> getCategoryChildren({
    required int parentCategoryId,
    int pageSize = 12,
    int page = 1,
    String? categoryType,
  });

  /// Turkum nomi bo'yicha qidirish (`/api/v1/category/search/?q=...`).
  /// Agar [categoryType] berilsa, faqat shu turdagi natijalar qaytariladi.
  Future<Either<Failure, List<CategoryEntity>>> searchCategories({
    required String query,
    String? categoryType,
    int pageSize = 20,
  });
}
