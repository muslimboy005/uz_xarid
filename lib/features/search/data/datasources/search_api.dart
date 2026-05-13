import 'package:dio/dio.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/features/catalog/data/models/catalog_ad_item_dto.dart';

/// Qidiruv API: GET ads/search/?search=...&page_size=...
class SearchApi {
  SearchApi(this._dio);

  final Dio _dio;

  Future<SearchResponseDto> search({
    required String query,
    int pageSize = 200,
    Map<String, dynamic>? extraParams,
  }) async {
    final queryParams = <String, dynamic>{
      'search': query.trim(),
      'page_size': pageSize,
    };
    if (extraParams != null) {
      queryParams.addAll(extraParams);
    }
    final response = await _dio.get<Map<String, dynamic>>(
      ApiUrls.adsSearch,
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
    return SearchResponseDto.fromJson(data);
  }
}

/// Javob: status, data.results, data.total_items, ...
class SearchResponseDto {
  const SearchResponseDto({required this.status, required this.data});

  final bool status;
  final SearchDataDto data;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) {
    return SearchResponseDto(
      status: json['status'] as bool? ?? false,
      data: SearchDataDto.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

class SearchDataDto {
  const SearchDataDto({
    required this.results,
    this.totalItems = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.pageSize = 200,
  });

  final List<CatalogAdItemDto> results;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  factory SearchDataDto.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>? ?? []).map((e) {
      return CatalogAdItemDto.fromJson(e as Map<String, dynamic>);
    }).toList();
    return SearchDataDto(
      results: list,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 200,
    );
  }
}
