import 'package:equatable/equatable.dart';

abstract class MyOrdersEvent extends Equatable {
  const MyOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyOrdersEvent extends MyOrdersEvent {
  final bool refresh;
  const LoadMyOrdersEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}
