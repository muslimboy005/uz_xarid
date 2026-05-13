import 'package:dio/dio.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failure.dart';
import 'package:uzxarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uzxarid/features/profile/data/model/profile_model.dart';
import 'package:uzxarid/features/profile/data/model/address_model.dart';
import 'package:uzxarid/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:uzxarid/features/profile/domain/entity/business_entity.dart';
import 'package:uzxarid/features/profile/domain/entity/full_name.dart';
import 'package:uzxarid/features/profile/data/model/plan_model.dart';
import 'package:uzxarid/features/profile/data/model/plan_history_model.dart';
import 'package:uzxarid/features/profile/data/model/chat/chat_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> sendOtp(String phone);
  Future<Either<Failure, ProfileModel>> confirmOtp(String phone, String otp);
  Future<Either<Failure, ProfileModel>> profileUpdate(
    ProfileUpdateEntity entity,
  );
  Future<Either<Failure, ProfileModel>> getProfile();
  Future<Either<Failure, ProfileModel>> resendOtp(String phone);

  Future<Either<Failure, ProfileModel>> getBusinessMe();
  Future<Either<Failure, ProfileModel>> createBusiness(BusinessEntity entity);
  Future<Either<Failure, ProfileModel>> updateBusiness(
    String id,
    BusinessEntity entity,
  );
  Future<Either<Failure, ProfileModel>> deleteBusiness(String id);
  Future<Either<Failure, ProfileModel>> updateBusinessImage(String id);
  Future<Either<Failure, ProfileModel>> getBusinessById(String id);

  Future<Either<Failure, AddressResponseModel>> getAddresses(
    int page,
    int pageSize,
  );
  Future<Either<Failure, AddressModel>> createAddress(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, AddressModel>> updateAddress(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteAddress(int id);

  Future<Either<Failure, dynamic>> getViewedAds(int page, int pageSize);
  Future<Either<Failure, void>> clearViewedAds();

  Future<Either<Failure, PlanResponseModel>> getPlans();
  Future<Either<Failure, PlanHistoryResponseModel>> getPlanHistory(
    int page,
    int pageSize,
  );

  Future<Either<Failure, ChatMessagesResponseModel>> getChatMessages(
    int chatRoomId,
    int page,
    int pageSize,
  );

  Future<Either<Failure, ChatMessagesResponseModel>> sendChatMessage(
    dynamic data,
  );

  factory ProfileRepository(ProfileApi profileDataSource, Dio dio) =>
      ProfileRepositoryImpl(profileDataSource: profileDataSource, dio: dio);
}
