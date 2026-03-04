import 'package:equatable/equatable.dart';

enum ProductFeedbackStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  submitSuccess,
  submitFailure,
}

class ProductFeedbackState extends Equatable {
  const ProductFeedbackState({
    this.status = ProductFeedbackStatus.initial,
    this.feedbacks,
    this.error,
  });

  final ProductFeedbackStatus status;
  final dynamic feedbacks; // Use dynamic since API response format is unknown
  final String? error;

  ProductFeedbackState copyWith({
    ProductFeedbackStatus? status,
    dynamic feedbacks,
    String? error,
  }) {
    return ProductFeedbackState(
      status: status ?? this.status,
      feedbacks: feedbacks ?? this.feedbacks,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, feedbacks, error];
}
