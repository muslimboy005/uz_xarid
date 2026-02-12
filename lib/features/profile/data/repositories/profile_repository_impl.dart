import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _profileDataSource;

  ProfileRepositoryImpl({required ProfileApi profileDataSource}) :
  _profileDataSource = profileDataSource;

  @override
  Future<Either<Failure, ProfileModel>> sendOtp(String phone) async {
    try {
      final result = await _profileDataSource.sendOtp(phone);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> confirmOtp(String phone, String otp) async {
    try{
      final result = await _profileDataSource.confirmOtp(phone, otp);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, ProfileModel>> profileUpdate(FullNameEntity fullName) async {
    try {
      final result = await _profileDataSource.profileUpdate(fullName);
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}