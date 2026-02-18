// MANUALLY WRITTEN (retrofit-like) - no build_runner run required.

part of 'home_api.dart';

class _HomeApi implements HomeApi {
  _HomeApi(this._dio, {this.baseUrl}) {
    baseUrl ??= ApiUrls.baseUrl;
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<CategoryResponseDto> getCategories(String categoryType) async {
    final queryParameters = <String, dynamic>{r'category_type': categoryType};
    final options = Options(method: 'GET').compose(
      _dio.options,
      ApiUrls.categories,
      queryParameters: queryParameters,
    );
    final result = await _dio.fetch<Map<String, dynamic>>(
      options.copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    return CategoryResponseDto.fromJson(result.data!);
  }

  @override
  Future<BannerResponseDto> getBanners() async {
    final options = Options(method: 'GET').compose(
      _dio.options,
      ApiUrls.banner,
    );
    final result = await _dio.fetch<Map<String, dynamic>>(
      options.copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    return BannerResponseDto.fromJson(result.data!);
  }

  @override
  Future<RecommendationResponseDto> getRecommendations(
    int pageSize,
    String adType,
  ) async {
    final queryParameters = <String, dynamic>{
      r'page_size': pageSize,
      r'ad_type': adType,
    };
    final options = Options(method: 'GET').compose(
      _dio.options,
      ApiUrls.recommendations,
      queryParameters: queryParameters,
    );
    final result = await _dio.fetch<Map<String, dynamic>>(
      options.copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    return RecommendationResponseDto.fromJson(result.data!);
  }

  @override
  Future<RecommendationResponseDto> getGifts(int pageSize) async {
    final queryParameters = <String, dynamic>{r'page_size': pageSize};
    final options = Options(method: 'GET').compose(
      _dio.options,
      ApiUrls.gifts,
      queryParameters: queryParameters,
    );
    final result = await _dio.fetch<Map<String, dynamic>>(
      options.copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    return RecommendationResponseDto.fromJson(result.data!);
  }

  @override
  Future<RecommendationResponseDto> getServices(int pageSize) async {
    final queryParameters = <String, dynamic>{r'page_size': pageSize};
    final options = Options(method: 'GET').compose(
      _dio.options,
      ApiUrls.services,
      queryParameters: queryParameters,
    );
    final result = await _dio.fetch<Map<String, dynamic>>(
      options.copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    return RecommendationResponseDto.fromJson(result.data!);
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) {
      return url.toString();
    }
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
