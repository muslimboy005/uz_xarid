import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:uz_xarid/features/profile/domain/entity/business_entity.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';

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

  factory ProfileRepository(ProfileApi profileDataSource, Dio dio) =>
      ProfileRepositoryImpl(profileDataSource: profileDataSource, dio: dio);
}
