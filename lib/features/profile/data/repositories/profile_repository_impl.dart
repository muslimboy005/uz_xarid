import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _profileDataSource;

  ProfileRepositoryImpl({required ProfileDatasource profileDataSource}) :
  _profileDataSource = profileDataSource;

  @override
  Future<Either<Failure, ProfileModel>> sendOtp(String phone) async {
    try {
      final result = await _profileDataSource.sentOtp(phone);
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
}