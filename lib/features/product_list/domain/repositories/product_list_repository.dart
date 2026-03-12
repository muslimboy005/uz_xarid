import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';

abstract class ProductListRepository {
  /// [searchQuery] berilsa – qidiruv API (ads/search); [categoryId] – turkum; null bo'lsa [listSource] bo'yicha.
  /// [adType] – tavsiyalar uchun 'Sell' yoki 'Buy'.
  Future<Either<Failure, List<ProductListItemEntity>>> getProducts({
    String? searchQuery,
    int? categoryId,
    String listSource = 'recommendations',
    int pageSize = 100,
    String adType = 'Sell',
    Map<String, dynamic>? filterParams,
    String? sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking' | null
  });
}
