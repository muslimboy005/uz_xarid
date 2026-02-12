part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({required this.status, required this.profileModel, required this.errorMessage, required this.otpModel});

  final ProfileStatus status;
  final ProfileModel? profileModel;
  final OtpModel? otpModel;
  final String? errorMessage;

  factory ProfileState.initial() {
    return ProfileState(status: ProfileStatus.initial, profileModel: null,otpModel: null, errorMessage: null);
  }

  ProfileState copyWith({ProfileStatus? status, ProfileModel? profileModel, OtpModel? otpModel, String? errorMessage}) {
    return ProfileState(
      status: status ?? this.status,
      profileModel: profileModel ?? this.profileModel,
      otpModel: otpModel ?? this.otpModel,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }

  @override
  List<Object?> get props => [status, profileModel, otpModel, errorMessage];
}
