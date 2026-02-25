import 'package:uz_xarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uz_xarid/features/catalog/data/models/catalog_ad_item_dto.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/home/data/models/recommendation_dto.dart';
import 'package:uz_xarid/features/product_list/data/models/product_list_item_dto.dart';

/// Mahsulotlar ro'yxati: tavsiyalar, xizmatlar yoki turkum bo'yicha ad API.
abstract class ProductListRemoteDatasource {
  Future<List<ProductListItemDto>> getRecommendations({
    int pageSize = 100,
    String adType = 'Sell',
  });

  Future<List<ProductListItemDto>> getServices({int pageSize = 100});

  Future<List<ProductListItemDto>> getGifts({int pageSize = 100});

  Future<List<ProductListItemDto>> getByCategory({
    required int categoryId,
    int page = 1,
    int pageSize = 10,
  });
}

class ProductListRemoteDatasourceImpl implements ProductListRemoteDatasource {
  ProductListRemoteDatasourceImpl({
    required this.homeApi,
    required this.catalogApi,
  });

  final HomeApi homeApi;
  final CatalogApi catalogApi;

  @override
  Future<List<ProductListItemDto>> getRecommendations({
    int pageSize = 100,
    String adType = 'Sell',
  }) async {
    final response = await homeApi.getRecommendations(pageSize, adType);
    return response.data.results.map(_fromRecommendationDto).toList();
  }

  @override
  Future<List<ProductListItemDto>> getServices({int pageSize = 100}) async {
    final response = await homeApi.getServices(pageSize);
    return response.data.results.map(_fromRecommendationDto).toList();
  }

  @override
  Future<List<ProductListItemDto>> getGifts({int pageSize = 100}) async {
    final response = await homeApi.getGifts(pageSize);
    return response.data.results.map(_fromRecommendationDto).toList();
  }

  @override
  Future<List<ProductListItemDto>> getByCategory({
    required int categoryId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await catalogApi.getAds(
      categoryId: categoryId,
      page: page,
      pageSize: pageSize,
    );
    return response.data.results.map(_fromCatalogAdItemDto).toList();
  }

  ProductListItemDto _fromRecommendationDto(RecommendationDto dto) {
    return ProductListItemDto(
      slug: dto.slug,
      title: dto.title,
      mainImage: dto.mainImage,
      price: dto.price,
      finalPrice: dto.finalPrice,
      currency: dto.currency,
      rating: dto.rating,
      reviewCount: dto.reviewCount,
    );
  }

  ProductListItemDto _fromCatalogAdItemDto(CatalogAdItemDto dto) {
    return ProductListItemDto(
      slug: dto.slug,
      title: dto.title,
      mainImage: dto.mainImage,
      price: dto.price,
      finalPrice: dto.finalPrice,
      currency: dto.currency,
      rating: dto.rating,
      reviewCount: dto.reviewCount,
    );
  }
}
