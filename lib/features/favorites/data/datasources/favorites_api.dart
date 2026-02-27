import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/favorites/data/models/favorites_dto.dart';

part 'favorites_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class FavoritesApi {
  factory FavoritesApi(Dio dio, {String? baseUrl}) = _FavoritesApi;

  @POST(ApiUrls.favoritesToggle)
  Future<FavoritesToggleResponseDto> toggle(@Body() Map<String, dynamic> body);

  @GET(ApiUrls.favoritesList)
  Future<FavoritesListResponseDto> getList(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );
}
