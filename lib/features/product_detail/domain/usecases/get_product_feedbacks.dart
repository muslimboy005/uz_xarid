import 'package:equatable/equatable.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/product_detail/domain/repositories/product_detail_repository.dart';

class GetProductFeedbacks
    implements UseCase<dynamic, GetProductFeedbacksParams> {
  const GetProductFeedbacks(this.repository);
  final ProductDetailRepository repository;

  @override
  Future<Either<Failure, dynamic>> call(GetProductFeedbacksParams params) {
    return repository.getFeedbacks(params.slug);
  }
}

class GetProductFeedbacksParams extends Equatable {
  const GetProductFeedbacksParams({required this.slug});
  final String slug;

  @override
  List<Object?> get props => [slug];
}
