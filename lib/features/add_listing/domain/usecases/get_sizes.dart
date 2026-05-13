import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uzxarid/features/add_listing/domain/repositories/listing_repository.dart';

class GetSizes
    extends UseCase<Either<Failure, List<SizeEntity>>, GetSizesParams> {
  GetSizes(this.repository);

  final ListingRepository repository;

  @override
  Future<Either<Failure, List<SizeEntity>>> call(GetSizesParams params) {
    return repository.getSizes(pageSize: params.pageSize);
  }
}

class GetSizesParams {
  const GetSizesParams({this.pageSize = 999});

  final int pageSize;
}
