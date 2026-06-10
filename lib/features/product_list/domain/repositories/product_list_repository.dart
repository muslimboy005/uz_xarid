import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/product_list/domain/entities/product_list_result.dart';

abstract class ProductListRepository {
  /// [searchQuery] berilsa – qidiruv API (ads/search); [categoryId] – turkum; null bo'lsa [listSource] bo'yicha.
  /// [adType] – tavsiyalar uchun 'Sell' yoki 'Buy'.
  /// [page] – 1 dan boshlanadigan sahifa raqami (infinite scroll uchun).
  Future<Either<Failure, ProductListResult>> getProducts({
    String? searchQuery,
    int? categoryId,
    String listSource = 'recommendations',
    int page = 1,
    int pageSize = 100,
    String adType = 'Sell',
    String? categoryType,
    Map<String, dynamic>? filterParams,
    String? sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking' | null
  });
}
