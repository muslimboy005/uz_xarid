import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/add_listing/data/models/color_dto.dart';
import 'package:uz_xarid/features/add_listing/data/models/size_dto.dart';

part 'listing_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class ListingApi {
  factory ListingApi(Dio dio, {String? baseUrl}) = _ListingApi;

  @GET(ApiUrls.color)
  Future<ColorResponseDto> getColors(
    @Query('page_size') int pageSize,
  );

  @GET(ApiUrls.size)
  Future<SizeResponseDto> getSizes(
    @Query('page_size') int pageSize,
  );
}
