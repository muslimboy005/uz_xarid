part of 'address_bloc.dart';

enum AddressStatus {
  initial,
  loading,
  success,
  failure,
  createSuccess,
  createFailure,
  updateSuccess,
  updateFailure,
  deleteSuccess,
  deleteFailure,
}

class AddressState extends Equatable {
  final AddressStatus status;
  final List<AddressModel> addresses;
  final String? errorMessage;
  final int? count;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.errorMessage,
    this.count,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<AddressModel>? addresses,
    String? errorMessage,
    int? count,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage ?? this.errorMessage,
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [status, addresses, errorMessage, count];
}
