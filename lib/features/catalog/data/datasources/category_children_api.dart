import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/catalog/data/models/category_children_page_dto.dart';

part 'category_children_api.g.dart';

@RestApi(baseUrl: ApiUrls.baseUrlV2)
abstract class CategoryChildrenApi {
  factory CategoryChildrenApi(Dio dio, {String baseUrl}) = _CategoryChildrenApi;

  @GET('category/{id}/children/')
  Future<CategoryChildrenPageDto> getCategoryChildren(
    @Path('id') int categoryId, {
    @Query('page_size') required int pageSize,
    @Query('page') int? page,
  });
}
