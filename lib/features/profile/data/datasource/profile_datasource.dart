import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/data/model/viewed_ads_response_model.dart';
import 'package:uz_xarid/features/profile/data/model/plan_model.dart';
import 'package:uz_xarid/features/profile/data/model/plan_history_model.dart';
import 'package:uz_xarid/features/profile/data/model/chat/chat_model.dart';
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

  @POST(ApiUrls.resendOtp)
  Future<ProfileModel> resendOtp(@Body() Map<String, dynamic> body);

  @GET(ApiUrls.businessMe)
  Future<ProfileModel> getBusinessMe();

  @POST(ApiUrls.business)
  @MultiPart()
  Future<ProfileModel> createBusiness(@Body() FormData body);

  @PUT(ApiUrls.businessId)
  @MultiPart()
  Future<ProfileModel> updateBusiness(
    @Path('id') String id,
    @Body() FormData body,
  );

  @DELETE(ApiUrls.businessDelete)
  Future<ProfileModel> deleteBusiness(@Path('id') String id);

  @PATCH(ApiUrls.businessId)
  @MultiPart()
  Future<ProfileModel> updateBusinessImage(
    @Path('id') String id,
    @Body() FormData body,
  );

  @GET(ApiUrls.businessId)
  Future<ProfileModel> getBusinessById(@Path('id') String id);

  @GET(ApiUrls.address)
  Future<AddressResponseModel> getAddresses(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @POST(ApiUrls.address)
  Future<AddressModel> createAddress(@Body() Map<String, dynamic> body);

  @PATCH('${ApiUrls.address}{id}/')
  Future<AddressModel> updateAddress(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('${ApiUrls.address}{id}/')
  Future<void> deleteAddress(@Path('id') int id);

  @GET(ApiUrls.viewedAds)
  Future<ViewedAdsResponseModel> getViewedAds(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @DELETE(ApiUrls.viewedAdsClear)
  Future<void> clearViewedAds();

  @GET(ApiUrls.plans)
  Future<PlanResponseModel> getPlans();

  @GET(ApiUrls.planHistory)
  Future<PlanHistoryResponseModel> getPlanHistory(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @GET(ApiUrls.chatMessages)
  Future<ChatMessagesResponseModel> getChatMessages(
    @Query('chat_room_id') int? chatRoomId,
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @POST(ApiUrls.chatMessages)
  Future<ChatMessagesResponseModel> sendChatMessage(
    @Body() dynamic body,
  );
}
