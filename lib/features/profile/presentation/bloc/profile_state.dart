part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthorized = false,
    this.authStep = ProfileAuthStep.none,
    this.firstName,
    this.lastName,
    this.phoneInput,
    this.otpInput,
  });

  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthorized;

  /// Simple auth flow state for UI (bottom sheets).
  ///
  /// 0 - none, 1 - phone, 2 - otp, 3 - name.
  final int authStep;

  final String? firstName;
  final String? lastName;
  final String? phoneInput;
  final String? otpInput;

  ProfileState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthorized,
    int? authStep,
    String? firstName,
    String? lastName,
    String? phoneInput,
    String? otpInput,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      authStep: authStep ?? this.authStep,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneInput: phoneInput ?? this.phoneInput,
      otpInput: otpInput ?? this.otpInput,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        phoneNumber,
        avatarUrl,
        isLoading,
        errorMessage,
        isAuthorized,
        authStep,
        firstName,
        lastName,
        phoneInput,
        otpInput,
      ];
}


class ProfileAuthStep {
  static const int none = 0;
  static const int phone = 1;
  static const int otp = 2;
  static const int name = 3;
}

