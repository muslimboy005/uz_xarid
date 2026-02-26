import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/profile/data/model/address_model.dart';
import 'package:uz_xarid/features/profile/domain/entity/page.dart';
import 'package:uz_xarid/features/profile/domain/usecase/profile_usecase.dart';

import 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final ProfileGetAddressesUsecase getAddressesUsecase;
  final ProfileCreateAddressUsecase createAddressUsecase;
  final ProfileUpdateAddressUsecase updateAddressUsecase;
  final ProfileDeleteAddressUsecase deleteAddressUsecase;

  AddressBloc({
    required this.getAddressesUsecase,
    required this.createAddressUsecase,
    required this.updateAddressUsecase,
    required this.deleteAddressUsecase,
  }) : super(const AddressState()) {
    on<LoadAddressesEvent>(_onLoadAddresses);
    on<CreateAddressEvent>(_onCreateAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(status: AddressStatus.loading));

    final result = await getAddressesUsecase.call(
      PageEntity(page: event.page, pageSize: event.pageSize),
    );

    result.either(
      (failure) => emit(
        state.copyWith(
          status: AddressStatus.failure,
          errorMessage: 'Xatolik yuz berdi: ${failure.message}',
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: AddressStatus.success,
          addresses: data.results,
          count: data.count,
        ),
      ),
    );
  }

  Future<void> _onCreateAddress(
    CreateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(status: AddressStatus.loading));

    final result = await createAddressUsecase.call(event.data);

    result.either(
      (failure) => emit(
        state.copyWith(
          status: AddressStatus.createFailure,
          errorMessage:
              'Manzil qoshishda xatolik yuz berdi: ${failure.message}',
        ),
      ),
      (success) {
        emit(state.copyWith(status: AddressStatus.createSuccess));
        // Reload addresses after creating
        add(const LoadAddressesEvent());
      },
    );
  }

  Future<void> _onUpdateAddress(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(status: AddressStatus.loading));

    final result = await updateAddressUsecase.call(
      AddressUpdateParams(id: event.id, data: event.data),
    );

    result.either(
      (failure) => emit(
        state.copyWith(
          status: AddressStatus.updateFailure,
          errorMessage:
              'Manzil yangilashda xatolik yuz berdi: ${failure.message}',
        ),
      ),
      (success) {
        emit(state.copyWith(status: AddressStatus.updateSuccess));
        // Reload addresses after updating
        add(const LoadAddressesEvent());
      },
    );
  }

  Future<void> _onDeleteAddress(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(status: AddressStatus.loading));

    final result = await deleteAddressUsecase.call(event.id);

    result.either(
      (failure) => emit(
        state.copyWith(
          status: AddressStatus.deleteFailure,
          errorMessage:
              'Manzil o`chirishda xatolik yuz berdi: ${failure.message}',
        ),
      ),
      (success) {
        emit(state.copyWith(status: AddressStatus.deleteSuccess));
        // Reload addresses after deleting
        add(const LoadAddressesEvent());
      },
    );
  }
}
