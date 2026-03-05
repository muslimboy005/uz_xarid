import 'package:bloc/bloc.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_product_feedbacks.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/leave_product_feedback.dart';

import 'product_feedback_event.dart';
import 'product_feedback_state.dart';

class ProductFeedbackBloc
    extends Bloc<ProductFeedbackEvent, ProductFeedbackState> {
  ProductFeedbackBloc(this._getFeedbacks, this._leaveFeedback)
    : super(const ProductFeedbackState()) {
    on<ProductFeedbackLoadRequested>(_onLoadRequested);
    on<ProductFeedbackLeaveRequested>(_onLeaveRequested);
  }

  final GetProductFeedbacks _getFeedbacks;
  final LeaveProductFeedback _leaveFeedback;

  Future<void> _onLoadRequested(
    ProductFeedbackLoadRequested event,
    Emitter<ProductFeedbackState> emit,
  ) async {
    emit(state.copyWith(status: ProductFeedbackStatus.loading, error: null));
    final result = await _getFeedbacks(
      GetProductFeedbacksParams(slug: event.slug),
    );
    if (result is Right<Failure, dynamic>) {
      emit(
        state.copyWith(
          status: ProductFeedbackStatus.success,
          feedbacks: result.right,
        ),
      );
    } else if (result is Left<Failure, dynamic>) {
      emit(
        state.copyWith(
          status: ProductFeedbackStatus.failure,
          error: result.left.message ?? 'Tarmoq xatosi',
        ),
      );
    }
  }

  Future<void> _onLeaveRequested(
    ProductFeedbackLeaveRequested event,
    Emitter<ProductFeedbackState> emit,
  ) async {
    emit(state.copyWith(status: ProductFeedbackStatus.submitting, error: null));
    final result = await _leaveFeedback(
      LeaveProductFeedbackParams(slug: event.slug, data: event.data),
    );
    if (result is Right<Failure, dynamic>) {
      emit(state.copyWith(status: ProductFeedbackStatus.submitSuccess));
      // Reload feedbacks after successful submission
      add(ProductFeedbackLoadRequested(slug: event.slug));
    } else if (result is Left<Failure, dynamic>) {
      emit(
        state.copyWith(
          status: ProductFeedbackStatus.submitFailure,
          error: result.left.message ?? 'Tarmoq xatosi',
        ),
      );
    }
  }
}
