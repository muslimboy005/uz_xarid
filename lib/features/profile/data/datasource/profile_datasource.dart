import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
part 'profile_datasource.g.dart';


@RestApi(baseUrl: ApiUrls.baseUrl)
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String baseUrl}) = _ProfileApi;

  @POST(ApiUrls.sendOtp)
  Future<ProfileModel> sendOtp(@Body() Map<String, dynamic> body);
  
  @POST(ApiUrls.confirmOtp)
  Future<ProfileModel> confirmOtp(@Body() Map<String, dynamic> body);
  
  @PATCH(ApiUrls.profileUpdate)
  Future<ProfileModel> profileUpdate(@Body() Map<String, dynamic> body);

  @GET(ApiUrls.getProfile)
  Future<ProfileModel> getProfile();
}
