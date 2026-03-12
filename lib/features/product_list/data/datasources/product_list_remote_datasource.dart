import 'package:uz_xarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uz_xarid/features/catalog/data/models/catalog_ad_item_dto.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/home/data/models/recommendation_dto.dart';
import 'package:uz_xarid/features/product_list/data/models/product_list_item_dto.dart';
import 'package:uz_xarid/features/search/data/datasources/search_api.dart';

/// Mahsulotlar ro'yxati: tavsiyalar, xizmatlar, qidiruv yoki turkum bo'yicha ad API.
abstract class ProductListRemoteDatasource {
  Future<List<ProductListItemDto>> getSearchResults({
    required String query,
    int pageSize = 200,
    Map<String, dynamic>? filterParams,
  });

  Future<List<ProductListItemDto>> getRecommendations({
    int pageSize = 100,
    String adType = 'Sell',
    String? sort, // 'popular' | 'cheap' | 'expensive' | 'high-ranking' | null
  });

  Future<List<ProductListItemDto>> getServices({int pageSize = 100});

  Future<List<ProductListItemDto>> getGifts({int pageSize = 100});

  Future<List<ProductListItemDto>> getByCategory({
    int? categoryId,
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filterParams,
  });

  Future<List<ProductListItemDto>> getFiltered({
    Map<String, dynamic>? filterParams,
    int pageSize = 100,
    String? adType,
  });
}

class ProductListRemoteDatasourceImpl implements ProductListRemoteDatasource {
  ProductListRemoteDatasourceImpl({
    required this.homeApi,
    required this.catalogApi,
    required this.searchApi,
  });

  final HomeApi homeApi;
  final CatalogApi catalogApi;
  final SearchApi searchApi;

  @override
  Future<List<ProductListItemDto>> getSearchResults({
    required String query,
    int pageSize = 200,
    Map<String, dynamic>? filterParams,
  }) async {
    final response = await searchApi.search(
      query: query,
      pageSize: pageSize,
      extraParams: filterParams,
    );
    return response.data.results.map(_fromCatalogAdItemDto).toList();
  }

  @override
  Future<List<ProductListItemDto>> getRecommendations({
    int pageSize = 100,
    String adType = 'Sell',
    String? sort,
  }) async {
    final response = await homeApi.getRecommendations(
      pageSize,
      adType,
      sort: sort,
    );
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
    int? categoryId,
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filterParams,
  }) async {
    final response = await catalogApi.getAds(
      categoryId: categoryId,
      page: page,
      pageSize: pageSize,
      extraParams: filterParams,
    );
    return response.data.results.map(_fromCatalogAdItemDto).toList();
  }

  @override
  Future<List<ProductListItemDto>> getFiltered({
    Map<String, dynamic>? filterParams,
    int pageSize = 100,
    String? adType,
  }) async {
    final extra = <String, dynamic>{
      if (filterParams != null) ...filterParams,
      if (adType != null) 'ad_type': adType,
    };
    final response = await catalogApi.getAds(
      pageSize: pageSize,
      extraParams: extra.isEmpty ? null : extra,
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
