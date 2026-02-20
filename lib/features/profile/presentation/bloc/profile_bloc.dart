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
  final ProfileUpdateUsecase profileUpdateUsecase;

  ProfileBloc(
    this.profileConfirmOtpUsecase,
    this.profileSendOtpUsecase,
    this.profileSignSubmitUsecase,
    this.profileGetUsecase,
    this.profileResendOtpUsecase,
    this.profileUpdateUsecase,
  ) : super(ProfileState.initial()) {
    on<ProfileSendOtpEvent>(_sendOtp);
    on<ProfileConfirmOtpEvent>(_confirmOtp);
    on<ProfileSignSubmitEvent>(_confirmSign);
    on<ProfileLogoutEvent>(_logout);
    on<ProfileLoadEvent>(_loadProfile);
    on<ProfileResendOtpEvent>(_resendOtp);
    on<ProfileUpdateEvent>(_updateProfile);
  }

  Future<void> _sendOtp(
    ProfileSendOtpEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileSendOtpUsecase(event.otpModel);
      result.either(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.toString(),
          ),
        ),
        (success) {
          if (success.status == false) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
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
      final result = await profileConfirmOtpUsecase(event.otpModel);
      result.either(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.toString(),
          ),
        ),
        (success) {
          if (success.status == false) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Kod xato',
              ),
            );
          } else {
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
      final result = await profileSignSubmitUsecase(event.fullNameEntity);
      result.either(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.toString(),
          ),
        ),
        (success) {
          if (success.status == false) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
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
    } catch (_) {}
  }

  Future<void> _loadProfile(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileGetUsecase(NoParams());
      result.either(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.toString(),
          ),
        ),
        (success) {
          if (success.status == false) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Profil yuklanmadi',
              ),
            );
          } else {
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
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileResendOtpUsecase(event.phone);
      result.either(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.toString(),
          ),
        ),
        (success) {
          if (success.status == false) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
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
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _updateProfile(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final result = await profileUpdateUsecase(
        ProfileUpdateEntity(
          firstName: event.firstName,
          lastName: event.lastName,
          phone: event.phone,
          email: event.email,
          gender: event.gender,
          birthDate: event.birthDate,
          city: event.city,
          street: event.street,
          house: event.house,
          district: event.district,
        ),
      );
      result.either(
        (failure) => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.toString(),
          ),
        ),
        (success) {
          if (success.status == false) {
            emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: success.data.detail ?? 'Xatolik yuz berdi',
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: ProfileStatus.updateSuccess,
                profileModel: success,
              ),
            );
          }
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
