import 'package:dio/dio.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/catalog/data/models/catalog_ad_item_dto.dart';

/// Katalog bo‘yicha e'lonlar ro‘yxati: /ad/?ad_type=Buy&category=...&listing_type=Product
class CatalogApi {
  CatalogApi(this._dio);

  final Dio _dio;

  /// [categoryId] – turkum id; null bo‘lsa barcha mahsulotlar so‘raladi.
  Future<CatalogAdListResponseDto> getAds({
    int? categoryId,
    String adType = 'Buy',
    String?
    listingType, // null = all types; pass 'Product','Auto', etc. to filter
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? extraParams,
  }) async {
    final queryParams = <String, dynamic>{
      'ad_type': adType,
      'page': page,
      'page_size': pageSize,
    };
    if (listingType != null) queryParams['listing_type'] = listingType;
    if (categoryId != null) queryParams['category'] = categoryId;
    if (extraParams != null) {
      queryParams.addAll(extraParams);
    }
    final response = await _dio.get<Map<String, dynamic>>(
      ApiUrls.ad,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Empty response',
      );
    }
    return CatalogAdListResponseDto.fromJson(data);
  }
}
