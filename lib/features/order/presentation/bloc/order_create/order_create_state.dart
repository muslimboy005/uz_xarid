import 'package:equatable/equatable.dart';

abstract class OrderCreateState extends Equatable {
  const OrderCreateState();

  @override
  List<Object?> get props => [];
}

class OrderCreateInitial extends OrderCreateState {}

class OrderCreateLoading extends OrderCreateState {}

class OrderCreateSuccess extends OrderCreateState {}

class OrderCreateFailure extends OrderCreateState {
  final String errorMessage;

  const OrderCreateFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
