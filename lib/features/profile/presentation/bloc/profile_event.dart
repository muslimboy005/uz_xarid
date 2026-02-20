part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileErrorCleared extends ProfileEvent {
  const ProfileErrorCleared();
}

class ProfileAuthFlowStarted extends ProfileEvent {
  const ProfileAuthFlowStarted();
}

class ProfileSendOtpEvent extends ProfileEvent {
  final String otpModel;
  const ProfileSendOtpEvent({required this.otpModel});
}

class ProfileResendOtpEvent extends ProfileEvent {
  final String phone;
  const ProfileResendOtpEvent({required this.phone});
}

class ProfileConfirmOtpEvent extends ProfileEvent {
  final OtpModel otpModel;
  const ProfileConfirmOtpEvent({required this.otpModel});
}

class ProfileSignSubmitEvent extends ProfileEvent {
  final FullNameEntity fullNameEntity;
  const ProfileSignSubmitEvent(this.fullNameEntity);
}

class ProfileLogoutEvent extends ProfileEvent {
  const ProfileLogoutEvent();
}

class ProfileLoadEvent extends ProfileEvent {
  const ProfileLoadEvent();
}

class ProfileUpdateEvent extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? city;
  final String? street;
  final String? house;
  final String? district;
  final String? gender;
  final String? birthDate;

  const ProfileUpdateEvent({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.city,
    this.street,
    this.house,
    this.district,
    this.gender,
    this.birthDate,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    city,
    street,
    house,
    district,
    gender,
    birthDate,
  ];
}
