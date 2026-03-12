import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/profile/data/model/plan_model.dart';
import 'package:uz_xarid/features/profile/data/model/plan_history_model.dart';

enum PaymentStatus { initial, loading, success, failure }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final PlanResponseModel? plans;
  final PlanHistoryResponseModel? history;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.plans,
    this.history,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    PlanResponseModel? plans,
    PlanHistoryResponseModel? history,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, plans, history, errorMessage];
}
