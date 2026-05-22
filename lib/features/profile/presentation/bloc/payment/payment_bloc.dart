import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/features/profile/data/model/plan_order_model.dart';
import 'package:uzxarid/features/profile/domain/repositories/profile_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ProfileRepository _repository;

  PaymentBloc({required ProfileRepository repository})
    : _repository = repository,
      super(const PaymentState()) {
    on<GetPaymentPlansEvent>(_onGetPaymentPlans);
    on<GetPaymentHistoryEvent>(_onGetPaymentHistory);
    on<CreatePlanOrderEvent>(_onCreatePlanOrder);
    on<ClearPaymentLinkEvent>(_onClearPaymentLink);
  }

  Future<void> _onGetPaymentPlans(
    GetPaymentPlansEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    final result = await _repository.getPlans();

    if (result.isRight) {
      emit(state.copyWith(status: PaymentStatus.success, plans: result.right));
    } else {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: result.left.message,
        ),
      );
    }
  }

  Future<void> _onCreatePlanOrder(
    CreatePlanOrderEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      state.copyWith(
        orderStatus: PlanOrderStatus.loading,
        orderingPlanId: event.userPlanId,
        clearOrder: false,
      ),
    );

    final result = await _repository.createPlanOrder(
      PlanOrderRequest(
        orderType: event.orderType,
        userPlanId: event.userPlanId,
        paymentMethod: event.paymentMethod,
      ),
    );

    if (result.isRight) {
      emit(
        state.copyWith(
          orderStatus: PlanOrderStatus.success,
          paymentLink: result.right.paymentLink,
        ),
      );
    } else {
      emit(
        state.copyWith(
          orderStatus: PlanOrderStatus.failure,
          orderErrorMessage: result.left.message,
        ),
      );
    }
  }

  Future<void> _onClearPaymentLink(
    ClearPaymentLinkEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(clearOrder: true));
  }

  Future<void> _onGetPaymentHistory(
    GetPaymentHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    // Only set loading if plans are already loaded or if this is the first history load
    if (state.plans == null) {
      emit(state.copyWith(status: PaymentStatus.loading));
    }

    final result = await _repository.getPlanHistory(event.page, event.pageSize);

    if (result.isRight) {
      emit(
        state.copyWith(status: PaymentStatus.success, history: result.right),
      );
    } else {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: result.left.message,
        ),
      );
    }
  }
}
