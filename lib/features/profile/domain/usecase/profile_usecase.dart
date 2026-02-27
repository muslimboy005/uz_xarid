import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failure.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:uz_xarid/features/profile/data/model/otp_model.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/entity/page.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uz_xarid/features/profile/domain/entity/business_entity.dart';

class ProfileSendOtpUsecase
    extends UseCase<Either<Failure, ProfileModel>, String> {
  final ProfileRepository profileRepository;
  ProfileSendOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String phone) async {
    return profileRepository.sendOtp(phone);
  }
}

class ProfileConfirmOtpUsecase
    extends UseCase<Either<Failure, ProfileModel>, OtpModel> {
  final ProfileRepository profileRepository;
  ProfileConfirmOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(OtpModel otp) async {
    return profileRepository.confirmOtp(otp.phone, otp.otp!);
  }
}

class ProfileSignSubmitUsecase
    extends UseCase<Either<Failure, ProfileModel>, FullNameEntity> {
  final ProfileRepository profileRepository;
  ProfileSignSubmitUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(FullNameEntity fullName) async {
    return profileRepository.profileUpdate(
      ProfileUpdateEntity(
        firstName: fullName.firstName,
        lastName: fullName.lastName,
      ),
    );
  }
}

class ProfileUpdateUsecase
    extends UseCase<Either<Failure, ProfileModel>, ProfileUpdateEntity> {
  final ProfileRepository profileRepository;
  ProfileUpdateUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(ProfileUpdateEntity entity) async {
    return profileRepository.profileUpdate(entity);
  }
}

class ProfileGetUsecase
    extends UseCase<Either<Failure, ProfileModel>, NoParams> {
  final ProfileRepository profileRepository;
  ProfileGetUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(NoParams param) {
    return profileRepository.getProfile();
  }
}

class ProfileResendOtpUsecase
    extends UseCase<Either<Failure, ProfileModel>, String> {
  final ProfileRepository profileRepository;
  ProfileResendOtpUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String phone) async {
    return profileRepository.resendOtp(phone);
  }
}

class ProfileGetBusinessMeUsecase
    extends UseCase<Either<Failure, ProfileModel>, NoParams> {
  final ProfileRepository profileRepository;
  ProfileGetBusinessMeUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(NoParams param) {
    return profileRepository.getBusinessMe();
  }
}

class ProfileCreateBusinessUsecase
    extends UseCase<Either<Failure, ProfileModel>, BusinessEntity> {
  final ProfileRepository profileRepository;
  ProfileCreateBusinessUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(BusinessEntity entity) {
    return profileRepository.createBusiness(entity);
  }
}

class BusinessUpdateParams {
  final String id;
  final BusinessEntity entity;
  BusinessUpdateParams({required this.id, required this.entity});
}

class ProfileUpdateBusinessUsecase
    extends UseCase<Either<Failure, ProfileModel>, BusinessUpdateParams> {
  final ProfileRepository profileRepository;
  ProfileUpdateBusinessUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(BusinessUpdateParams params) {
    return profileRepository.updateBusiness(params.id, params.entity);
  }
}

class ProfileDeleteBusinessUsecase
    extends UseCase<Either<Failure, ProfileModel>, String> {
  final ProfileRepository profileRepository;
  ProfileDeleteBusinessUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String id) {
    return profileRepository.deleteBusiness(id);
  }
}

class ProfileUpdateBusinessImageUsecase
    extends UseCase<Either<Failure, ProfileModel>, String> {
  final ProfileRepository profileRepository;
  ProfileUpdateBusinessImageUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String id) {
    return profileRepository.updateBusinessImage(id);
  }
}

class ProfileGetBusinessByIdUsecase
    extends UseCase<Either<Failure, ProfileModel>, String> {
  final ProfileRepository profileRepository;
  ProfileGetBusinessByIdUsecase(this.profileRepository);
  @override
  Future<Either<Failure, ProfileModel>> call(String id) {
    return profileRepository.getBusinessById(id);
  }
}

class ProfileGetAddressesUsecase
    extends UseCase<Either<Failure, AddressResponseModel>, PageEntity> {
  final ProfileRepository profileRepository;
  ProfileGetAddressesUsecase(this.profileRepository);
  @override
  Future<Either<Failure, AddressResponseModel>> call(PageEntity param) {
    return profileRepository.getAddresses(param.page, param.pageSize);
  }
}

class ProfileCreateAddressUsecase
    extends UseCase<Either<Failure, AddressModel>, Map<String, dynamic>> {
  final ProfileRepository profileRepository;
  ProfileCreateAddressUsecase(this.profileRepository);
  @override
  Future<Either<Failure, AddressModel>> call(Map<String, dynamic> data) {
    return profileRepository.createAddress(data);
  }
}

class AddressUpdateParams {
  final int id;
  final Map<String, dynamic> data;
  AddressUpdateParams({required this.id, required this.data});
}

class ProfileUpdateAddressUsecase
    extends UseCase<Either<Failure, AddressModel>, AddressUpdateParams> {
  final ProfileRepository profileRepository;
  ProfileUpdateAddressUsecase(this.profileRepository);
  @override
  Future<Either<Failure, AddressModel>> call(AddressUpdateParams params) {
    return profileRepository.updateAddress(params.id, params.data);
  }
}

class ProfileDeleteAddressUsecase extends UseCase<Either<Failure, void>, int> {
  final ProfileRepository profileRepository;
  ProfileDeleteAddressUsecase(this.profileRepository);
  @override
  Future<Either<Failure, void>> call(int id) {
    return profileRepository.deleteAddress(id);
  }
}
