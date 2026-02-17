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
  final  String otpModel;
  const ProfileSendOtpEvent({required this.otpModel});
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
