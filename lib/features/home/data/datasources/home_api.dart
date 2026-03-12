import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/home/data/models/banner_dto.dart';
import 'package:uz_xarid/features/home/data/models/category_dto.dart';
import 'package:uz_xarid/features/home/data/models/recommendation_dto.dart';

part 'home_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class HomeApi {
  factory HomeApi(Dio dio, {String baseUrl}) = _HomeApi;

  @GET(ApiUrls.categories)
  Future<CategoryResponseDto> getCategories(
    @Query('category_type') String categoryType,
  );

  @GET(ApiUrls.banner)
  Future<BannerResponseDto> getBanners();

  @GET(ApiUrls.recommendations)
  Future<RecommendationResponseDto> getRecommendations(
    @Query('page_size') int pageSize,
    @Query('ad_type') String adType, {
    @Query('sort') String? sort,
  });

  @GET(ApiUrls.gifts)
  Future<RecommendationResponseDto> getGifts(@Query('page_size') int pageSize);

  @GET(ApiUrls.services)
  Future<RecommendationResponseDto> getServices(
    @Query('page_size') int pageSize,
  );
}

class RecommendationResponseDto {
  final bool status;
  final RecommendationResponseData data;

  RecommendationResponseDto({required this.status, required this.data});

  factory RecommendationResponseDto.fromJson(Map<String, dynamic> json) {
    return RecommendationResponseDto(
      status: json['status'] as bool? ?? false,
      data: RecommendationResponseData.fromJson(
        json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class RecommendationResponseData {
  final List<RecommendationDto> results;

  RecommendationResponseData({required this.results});

  factory RecommendationResponseData.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>? ?? const []).map((e) {
      return RecommendationDto.fromJson(e as Map<String, dynamic>);
    }).toList();
    return RecommendationResponseData(results: list);
  }
}
