import 'package:equatable/equatable.dart';

abstract class ProductFeedbackEvent extends Equatable {
  const ProductFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class ProductFeedbackLoadRequested extends ProductFeedbackEvent {
  const ProductFeedbackLoadRequested({required this.slug});
  final String slug;

  @override
  List<Object?> get props => [slug];
}

class ProductFeedbackLeaveRequested extends ProductFeedbackEvent {
  const ProductFeedbackLeaveRequested({required this.slug, required this.data});
  final String slug;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [slug, data];
}
