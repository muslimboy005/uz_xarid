import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/home/data/models/category_dto.dart';

part 'home_category_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class HomeCategoryApi {
  factory HomeCategoryApi(Dio dio, {String baseUrl}) = _HomeCategoryApi;

  @GET(ApiUrls.categories)
  Future<CategoryResponseDto> getCategories(
    @Query('category_type') String categoryType,
  );
}
