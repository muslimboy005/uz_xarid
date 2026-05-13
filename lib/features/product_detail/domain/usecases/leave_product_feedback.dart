import 'package:equatable/equatable.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/product_detail/domain/repositories/product_detail_repository.dart';

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
