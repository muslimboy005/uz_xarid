import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';

abstract class ProductListRepository {
  /// [categoryId] berilsa – shu turkum bo'yicha; null bo'lsa [listSource] bo'yicha (recommendations | services | gifts).
  Future<Either<Failure, List<ProductListItemEntity>>> getProducts({
    int? categoryId,
    String listSource = 'recommendations',
    int pageSize = 100,
  });
}
