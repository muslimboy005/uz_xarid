import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/profile/data/model/plan_model.dart';
import 'package:uzxarid/features/profile/data/model/plan_history_model.dart';

enum PaymentStatus { initial, loading, success, failure }

enum PlanOrderStatus { initial, loading, success, failure }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final PlanResponseModel? plans;
  final PlanHistoryResponseModel? history;
  final String? errorMessage;

  final PlanOrderStatus orderStatus;
  final String? paymentLink;
  final String? orderErrorMessage;
  final int? orderingPlanId;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.plans,
    this.history,
    this.errorMessage,
    this.orderStatus = PlanOrderStatus.initial,
    this.paymentLink,
    this.orderErrorMessage,
    this.orderingPlanId,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    PlanResponseModel? plans,
    PlanHistoryResponseModel? history,
    String? errorMessage,
    PlanOrderStatus? orderStatus,
    String? paymentLink,
    String? orderErrorMessage,
    int? orderingPlanId,
    bool clearOrder = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
      orderStatus: clearOrder
          ? PlanOrderStatus.initial
          : (orderStatus ?? this.orderStatus),
      paymentLink: clearOrder ? null : (paymentLink ?? this.paymentLink),
      orderErrorMessage: clearOrder
          ? null
          : (orderErrorMessage ?? this.orderErrorMessage),
      orderingPlanId: clearOrder
          ? null
          : (orderingPlanId ?? this.orderingPlanId),
    );
  }

  @override
  List<Object?> get props => [
    status,
    plans,
    history,
    errorMessage,
    orderStatus,
    paymentLink,
    orderErrorMessage,
    orderingPlanId,
  ];
}
