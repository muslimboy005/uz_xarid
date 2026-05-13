import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/features/product_detail/data/models/ad_detail_dto.dart';

part 'product_detail_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class ProductDetailApi {
  factory ProductDetailApi(Dio dio, {String? baseUrl}) = _ProductDetailApi;

  @GET('ad/{slug}/')
  Future<AdDetailResponseDto> getAdDetail(@Path('slug') String slug);

  @GET('ad/{slug}/similar/')
  Future<AdSimilarResponseDto> getSimilar(@Path('slug') String slug);

  @GET(ApiUrls.color)
  Future<ColorListResponseDto> getColors(@Query('page_size') int pageSize);

  @GET(ApiUrls.size)
  Future<SizeListResponseDto> getSizes(@Query('page_size') int pageSize);

  @GET('ad/{slug}/feedback/')
  Future<dynamic> getFeedbacks(@Path('slug') String slug);

  @POST('ad/{slug}/feedback/')
  Future<dynamic> leaveFeedback(
    @Path('slug') String slug,
    @Body() Map<String, dynamic> body,
  );
}
