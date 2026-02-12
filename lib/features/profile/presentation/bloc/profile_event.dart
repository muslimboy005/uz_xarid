part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
  });

  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;

  @override
  List<Object?> get props => [fullName, email, phoneNumber, avatarUrl];
}

class ProfileErrorCleared extends ProfileEvent {
  const ProfileErrorCleared();
}

class ProfileAuthFlowStarted extends ProfileEvent {
  const ProfileAuthFlowStarted();
}

class ProfilePhoneSubmitted extends ProfileEvent {
  const ProfilePhoneSubmitted(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class ProfileOtpSubmitted extends ProfileEvent {
  const ProfileOtpSubmitted(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];
}

class ProfileNameSubmitted extends ProfileEvent {
  const ProfileNameSubmitted({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  @override
  List<Object?> get props => [firstName, lastName];
}
