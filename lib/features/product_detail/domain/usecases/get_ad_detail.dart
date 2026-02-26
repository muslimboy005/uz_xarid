import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/product_detail/domain/repositories/product_detail_repository.dart';

class GetAdDetail
    extends UseCase<Either<Failure, AdDetailEntity>, GetAdDetailParams> {
  GetAdDetail(this.repository);

  final ProductDetailRepository repository;

  @override
  Future<Either<Failure, AdDetailEntity>> call(GetAdDetailParams params) {
    return repository.getAdDetail(params.slug);
  }
}

class GetAdDetailParams {
  const GetAdDetailParams({required this.slug});

  final String slug;
}
