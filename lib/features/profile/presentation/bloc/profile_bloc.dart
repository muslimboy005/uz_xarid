import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/profile/data/model/otp_model.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/full_name.dart';
import 'package:uz_xarid/features/profile/domain/usecase/profile_usecase.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileSendOtpUsecase profileSendOtpUsecase;
  final ProfileConfirmOtpUsecase profileConfirmOtpUsecase;
  final ProfileSignSubmitUsecase profileSignSubmitUsecase;
  final ProfileGetUsecase profileGetUsecase;
  final ProfileResendOtpUsecase profileResendOtpUsecase;

  ProfileBloc(
    this.profileConfirmOtpUsecase,
    this.profileSendOtpUsecase,
    this.profileSignSubmitUsecase,
    this.profileGetUsecase,
    this.profileResendOtpUsecase,
  ) : super(ProfileState.initial()) {
    on<ProfileSendOtpEvent>(_sendOtp);
    on<ProfileConfirmOtpEvent>(_confirmOtp);
    on<ProfileSignSubmitEvent>(_confirmSign);
    on<ProfileLogoutEvent>(_logout);
    on<ProfileLoadEvent>(_loadProfile);
    on<ProfileResendOtpEvent>(_resendOtp);
  }

  Future<void> _sendOtp(
    ProfileSendOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      print('🚀 ProfileBloc: Sending OTP to ${event.otpModel}');

      final result = await profileSendOtpUsecase(event.otpModel);

      result.either(
        (failure) {
          print('❌ ProfileBloc: Send OTP Failed: ${failure.toString()}');
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          if (success.status == false) {
            print(
              '⚠️ ProfileBloc: Send OTP Status False: ${success.data.detail}',
            );
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
            print('✅ ProfileBloc: OTP Sent: ${success.data.detail}');
            emit(
              state.copyWith(
                status: ProfileStatus.success,
                profileModel: success,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ ProfileBloc: Exception in sendOtp: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _confirmOtp(
    ProfileConfirmOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      print('🚀 ProfileBloc: Confirming OTP...');

      final result = await profileConfirmOtpUsecase(event.otpModel);

      result.either(
        (failure) {
          print('❌ ProfileBloc: OTP Confirm Failed: ${failure.toString()}');
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          if (success.status == false) {
            print(
              '⚠️ ProfileBloc: Confirm OTP Status False: ${success.data.detail}',
            );
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Kod xato',
              ),
            );
          } else {
            print('✅ ProfileBloc: OTP Confirmed Successfully');
            print('AskName: ${success.data.askName}');
            print('User: ${success.data.user?.firstName}');

            emit(
              state.copyWith(
                status: ProfileStatus.success,
                profileModel: success,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ ProfileBloc: Exception in confirmOtp: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _confirmSign(
    ProfileSignSubmitEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      print('🚀 ProfileBloc: Submitting Name...');

      final result = await profileSignSubmitUsecase(event.fullNameEntity);

      result.either(
        (failure) {
          print('❌ ProfileBloc: Profile Update Failed: ${failure.toString()}');
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          if (success.status == false) {
            print(
              '⚠️ ProfileBloc: Profile Update Status False: ${success.data.detail}',
            );
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
            print('✅ ProfileBloc: Profile Updated Successfully');
            print('AskName: ${success.data.askName}');
            print('User: ${success.data.user}');
            emit(
              state.copyWith(
                status: ProfileStatus.success,
                profileModel: success,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ ProfileBloc: Exception in confirmSign: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _logout(
    ProfileLogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (!emit.isDone) {
        emit(ProfileState.initial());
      }
      print('✅ ProfileBloc: User logged out');
    } catch (e) {
      print('❌ ProfileBloc: Logout error: $e');
    }
  }

  Future<void> _loadProfile(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      print('🚀 ProfileBloc: Loading Profile...');
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileGetUsecase(NoParams());
      result.either(
        (failure) {
          print('❌ ProfileBloc: Load Profile Failed: ${failure.toString()}');
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          if (success.status == false) {
            print(
              '⚠️ ProfileBloc: Load Profile Status False: ${success.data.detail}',
            );
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Profil yuklanmadi',
              ),
            );
          } else {
            print('✅ ProfileBloc: Profile Loaded Successfully');
            emit(
              state.copyWith(
                status: ProfileStatus.success,
                profileModel: success,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ ProfileBloc: Exception in loadProfile: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _resendOtp(
    ProfileResendOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      print('🚀 ProfileBloc: Resending OTP...');
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileResendOtpUsecase(event.phone);
      result.either(
        (failure) {
          print('❌ ProfileBloc: Resend OTP Failed: ${failure.toString()}');
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          if (success.status == false) {
            print(
              '⚠️ ProfileBloc: Resend OTP Status False: ${success.data.detail}',
            );
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
            print('✅ ProfileBloc: OTP Resend Successfully');
            emit(
              state.copyWith(
                status: ProfileStatus.success,
                profileModel: success,
              ),
            );
          }
        },
      );
    } catch (e) {
      print('❌ ProfileBloc: Exception in resendOtp: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
