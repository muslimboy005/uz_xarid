import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/product_detail/domain/repositories/product_detail_repository.dart';

class LeaveProductFeedback
    implements UseCase<dynamic, LeaveProductFeedbackParams> {
  const LeaveProductFeedback(this.repository);
  final ProductDetailRepository repository;

  @override
  Future<Either<Failure, dynamic>> call(LeaveProductFeedbackParams params) {
    return repository.leaveFeedback(params.slug, params.data);
  }
}

class LeaveProductFeedbackParams extends Equatable {
  const LeaveProductFeedbackParams({required this.slug, required this.data});
  final String slug;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [slug, data];
}
