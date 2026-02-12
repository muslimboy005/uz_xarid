part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

// class ProfileUpdated extends ProfileEvent {
//   const ProfileUpdated({
//     this.fullName,
//     this.email,
//     this.phoneNumber,
//     this.avatarUrl,
//   });

//   final String? fullName;
//   final String? email;
//   final String? phoneNumber;
//   final String? avatarUrl;

//   @override
//   List<Object?> get props => [fullName, email, phoneNumber, avatarUrl];
// }

class ProfileErrorCleared extends ProfileEvent {
  const ProfileErrorCleared();
}

class ProfileAuthFlowStarted extends ProfileEvent {
  const ProfileAuthFlowStarted();
}

class ProfileSendOtpEvent extends ProfileEvent {
  final  OtpModel otpModel;
  const ProfileSendOtpEvent({required this.otpModel});
}

class ProfileConfirmOtpEvent extends ProfileEvent {
  final String otp;
  final String phone;
  const ProfileConfirmOtpEvent(this.otp, this.phone);
}

class ProfileSignSubmitEvent extends ProfileEvent {
  final FullNameEntity fullNameEntity;
  const ProfileSignSubmitEvent(this.fullNameEntity);
}
