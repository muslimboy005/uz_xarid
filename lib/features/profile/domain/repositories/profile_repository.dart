import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> sendOtp(String phone);
  Future<Either<Failure, ProfileModel>> confirmOtp(String otp, String phone);
  Future<Either<Failure, ProfileModel>> profileUpdate(FullNameEntity fullName);
  Future<Either<Failure, ProfileModel>> getProfile();
  Future<Either<Failure, ProfileModel>> resendOtp(String phone);

  factory ProfileRepository(ProfileApi profileDataSource) =>
       ProfileRepositoryImpl(profileDataSource: profileDataSource);
}