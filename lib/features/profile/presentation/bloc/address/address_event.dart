import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddressesEvent extends AddressEvent {
  final int page;
  final int pageSize;

  const LoadAddressesEvent({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}

class CreateAddressEvent extends AddressEvent {
  final Map<String, dynamic> data;

  const CreateAddressEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateAddressEvent extends AddressEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateAddressEvent(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteAddressEvent extends AddressEvent {
  final int id;

  const DeleteAddressEvent(this.id);

  @override
  List<Object?> get props => [id];
}
