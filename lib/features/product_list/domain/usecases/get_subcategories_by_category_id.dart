import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/product_list/domain/entities/subcategory_item.dart';

/// [categoryId] berilganda: `GET /api/v2/category/{id}/children/?page_size=…` orqali podturkumlar.
/// [categoryId] null bo‘lsa: ildiz turkumlar (v1 daraxt).
class GetSubcategoriesByCategoryId {
  GetSubcategoriesByCategoryId(this._catalogRepository);

  final CatalogRepository _catalogRepository;

  Future<Either<Failure, List<SubcategoryItem>>> call(
    GetSubcategoriesByCategoryIdParams params,
  ) async {
    if (params.categoryId != null) {
      final result = await _catalogRepository.getCategoryChildren(
        parentCategoryId: params.categoryId!,
        pageSize: params.pageSize,
        page: params.page,
      );
      if (result is Left<Failure, List<CategoryEntity>>) {
        return Left(result.left);
      }
      final children =
          (result as Right<Failure, List<CategoryEntity>>).right;
      final list = children
          .map(
            (c) =>
                SubcategoryItem(id: c.id, name: c.displayName, image: c.image),
          )
          .toList();
      return Right(list);
    }

    final result = await _catalogRepository.getCategories(
      categoryType: params.categoryType,
    );
    if (result is Left<Failure, List<CategoryEntity>>) {
      return Left(result.left);
    }
    final roots = (result as Right<Failure, List<CategoryEntity>>).right;

    final list = roots
        .map(
          (c) =>
              SubcategoryItem(id: c.id, name: c.displayName, image: c.image),
        )
        .toList();
    return Right(list);
  }
}

class GetSubcategoriesByCategoryIdParams {
  const GetSubcategoriesByCategoryIdParams({
    this.categoryId,
    this.categoryType = 'Product',
    this.pageSize = 12,
    this.page = 1,
  });

  final int? categoryId;
  final String categoryType;

  /// v2 children endpoint uchun (masalan 12).
  final int pageSize;

  /// Sahifa raqami (1 dan boshlanadi).
  final int page;
}
