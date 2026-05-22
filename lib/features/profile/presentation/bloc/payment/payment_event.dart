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

class CreatePlanOrderEvent extends PaymentEvent {
  final int userPlanId;
  final String paymentMethod;
  final String orderType;

  const CreatePlanOrderEvent({
    required this.userPlanId,
    required this.paymentMethod,
    this.orderType = 'user_plan',
  });

  @override
  List<Object?> get props => [userPlanId, paymentMethod, orderType];
}

class ClearPaymentLinkEvent extends PaymentEvent {
  const ClearPaymentLinkEvent();
}
