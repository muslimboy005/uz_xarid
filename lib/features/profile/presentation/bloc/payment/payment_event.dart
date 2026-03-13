import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class GetPaymentPlansEvent extends PaymentEvent {
  const GetPaymentPlansEvent();
}

class GetPaymentHistoryEvent extends PaymentEvent {
  final int page;
  final int pageSize;

  const GetPaymentHistoryEvent({this.page = 1, this.pageSize = 10});

  @override
  List<Object?> get props => [page, pageSize];
}
