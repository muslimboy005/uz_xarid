import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/product_list/domain/entities/subcategory_item.dart';

/// Berilgan [categoryId] va [categoryType] bo‘yicha turkum daraxtidan shu turkumning bolalarini qaytaradi.
class GetSubcategoriesByCategoryId {
  GetSubcategoriesByCategoryId(this._catalogRepository);

  final CatalogRepository _catalogRepository;

  Future<Either<Failure, List<SubcategoryItem>>> call(
    GetSubcategoriesByCategoryIdParams params,
  ) async {
    final result = await _catalogRepository.getCategories(
      categoryType: params.categoryType,
    );
    if (result is Left<Failure, List<CategoryEntity>>) {
      return Left(result.left);
    }
    final roots = (result as Right<Failure, List<CategoryEntity>>).right;
    final category = _findCategoryById(roots, params.categoryId);
    if (category == null) return Right([]);
    final list = category.children
        .map(
          (c) => SubcategoryItem(id: c.id, name: c.displayName, image: c.image),
        )
        .toList();
    return Right(list);
  }

  static CategoryEntity? _findCategoryById(
    List<CategoryEntity> nodes,
    int categoryId,
  ) {
    for (final node in nodes) {
      if (node.id == categoryId) return node;
      final found = _findCategoryById(node.children, categoryId);
      if (found != null) return found;
    }
    return null;
  }
}

class GetSubcategoriesByCategoryIdParams {
  const GetSubcategoriesByCategoryIdParams({
    required this.categoryId,
    this.categoryType = 'Product',
  });

  final int categoryId;
  final String categoryType;
}
