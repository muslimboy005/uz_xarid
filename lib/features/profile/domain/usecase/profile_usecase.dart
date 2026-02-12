import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/profile/data/model/otp_model.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

class ProfileSendOtpUsecase
    extends UseCase<Either<Failure, ProfileModel>, OtpModel> {
  final ProfileRepository profileRepository;
  ProfileSendOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(OtpModel otp) {
    return profileRepository.sendOtp(otp.phone);
  }
}

class ProfileConfirmOtpUsecase
    extends UseCase<Either<Failure, ProfileModel>, OtpModel> {
  final ProfileRepository profileRepository;
  ProfileConfirmOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(OtpModel otp) async {
    return profileRepository.confirmOtp(otp.otp, otp.phone);
  }
}
