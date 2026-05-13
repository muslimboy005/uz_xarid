import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/features/add_listing/data/models/color_dto.dart';
import 'package:uzxarid/features/add_listing/data/models/location_place_dto.dart';
import 'package:uzxarid/features/add_listing/data/models/size_dto.dart';

part 'listing_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class ListingApi {
  factory ListingApi(Dio dio, {String? baseUrl}) = _ListingApi;

  @GET(ApiUrls.color)
  Future<ColorResponseDto> getColors(@Query('page_size') int pageSize);

  @GET(ApiUrls.size)
  Future<SizeResponseDto> getSizes(@Query('page_size') int pageSize);

  @GET(ApiUrls.region)
  Future<LocationPagedResponseDto> getRegions(@Query('page') int page);

  @GET(ApiUrls.district)
  Future<LocationPagedResponseDto> getDistricts(
    @Query('page') int page,
    @Query('region') int regionId,
  );

  @GET(ApiUrls.neighborhood)
  Future<LocationPagedResponseDto> getNeighborhoods(
    @Query('page') int page,
    @Query('district') int districtId,
  );
}
