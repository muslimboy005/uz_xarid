import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> sendOtp(String phone);
  Future<Either<Failure, ProfileModel>> confirmOtp(String otp, String phone);
}