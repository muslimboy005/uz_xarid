import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  ProfileBloc(
    this.profileConfirmOtpUsecase,
    this.profileSendOtpUsecase,
    this.profileSignSubmitUsecase,
  ) : super(ProfileState.initial()) {
    on<ProfileSendOtpEvent>(_sendOtp);
    on<ProfileConfirmOtpEvent>(_confirmOtp);
    on<ProfileSignSubmitEvent>(_confirmSign);
  }

  Future<void> _sendOtp(
    ProfileSendOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileSendOtpUsecase(event.otpModel);
      result.either(
        (failure) {
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          // success bu ProfileModel
          emit(
            state.copyWith(
              status: ProfileStatus.success,
              profileModel: success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _confirmOtp(ProfileConfirmOtpEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileConfirmOtpUsecase(event.otpModel);
       result.either(
        (failure) {
          emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.toString(),
            ),
          );
        },
        (success) {
          // success bu ProfileModel
          emit(
            state.copyWith(
              status: ProfileStatus.success,
              profileModel: success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _confirmSign(ProfileSignSubmitEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileSignSubmitUsecase(event.fullNameEntity);
      result.either(
        (failure) {
          emit(state.copyWith(status: ProfileStatus.failure, errorMessage: failure.toString()));
        },
        (success) {
          emit(state.copyWith(status: ProfileStatus.success, profileModel: success));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
