import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileErrorCleared>(_onErrorCleared);
    on<ProfileAuthFlowStarted>(_onAuthFlowStarted);
    on<ProfilePhoneSubmitted>(_onPhoneSubmitted);
    on<ProfileOtpSubmitted>(_onOtpSubmitted);
    on<ProfileNameSubmitted>(_onNameSubmitted);
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // TODO: implement real profile loading logic using a repository

      emit(
        state.copyWith(
          isLoading: false,
          // You can pre-fill mock data here if needed
          // fullName: 'User Name',
          // email: 'user@example.com',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        fullName: event.fullName ?? state.fullName,
        email: event.email ?? state.email,
        phoneNumber: event.phoneNumber ?? state.phoneNumber,
        avatarUrl: event.avatarUrl ?? state.avatarUrl,
      ),
    );
  }

  void _onErrorCleared(
    ProfileErrorCleared event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(errorMessage: null));
  }

  void _onAuthFlowStarted(
    ProfileAuthFlowStarted event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        authStep: ProfileAuthStep.phone,
        phoneInput: null,
        otpInput: null,
      ),
    );
  }

  void _onPhoneSubmitted(
    ProfilePhoneSubmitted event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        phoneInput: event.phone,
        authStep: ProfileAuthStep.otp,
      ),
    );
  }

  void _onOtpSubmitted(
    ProfileOtpSubmitted event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        otpInput: event.otp,
        authStep: ProfileAuthStep.name,
      ),
    );
  }

  void _onNameSubmitted(
    ProfileNameSubmitted event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        fullName: '${event.firstName} ${event.lastName}',
        phoneNumber: state.phoneInput,
        isAuthorized: true,
        authStep: ProfileAuthStep.none,
      ),
    );
  }
}
