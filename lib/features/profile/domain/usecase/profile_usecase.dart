import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/profile/data/model/otp_model.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';


class ProfileSendOtpUsecase extends UseCase<Either<Failure, ProfileModel>,String> {
  final ProfileRepository profileRepository;
  ProfileSendOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String phone) async {


  }
}


class ProfileConfirmOtpUsecase extends UseCase<Either<Failure, ProfileModel>, OtpModel> {

  final ProfileRepository profileRepository;
  ProfileConfirmOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(OtpModel otp) async {
    return profileRepository.confirmOtp(otp.phone, otp.otp!);
  }
}

class ProfileSignSubmitUsecase extends UseCase<Either<Failure, ProfileModel>, FullNameEntity> {
  final ProfileRepository profileRepository;
  ProfileSignSubmitUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(FullNameEntity fullName) async {
    return profileRepository.profileUpdate(fullName);
  }
}

class ProfileGetUsecase extends UseCase<Either<Failure, ProfileModel>, NoParams> {
  final ProfileRepository profileRepository;
  ProfileGetUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(NoParams param) {
  return profileRepository.getProfile();
  }
}

class ProfileResendOtpUsecase extends UseCase<Either<Failure, ProfileModel>, String> {
  final ProfileRepository profileRepository;
  ProfileResendOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String phone) async {
    return profileRepository.resendOtp(phone);
  }
}

