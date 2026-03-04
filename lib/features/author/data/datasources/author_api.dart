import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:uz_xarid/features/author/data/models/author_dto.dart';

part 'author_api.g.dart';

@RestApi()
abstract class AuthorApi {
  factory AuthorApi(Dio dio, {String baseUrl}) = _AuthorApi;

  @GET('ad/author/{userId}/')
  Future<AuthorResponseDto> getAuthorAds(
    @Path('userId') int userId,
    @Query('page') int page,
  );
}
