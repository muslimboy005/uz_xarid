import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uzxarid/features/add_listing/domain/entities/create_ad_result.dart';
import 'package:uzxarid/features/add_listing/domain/repositories/listing_repository.dart';

class CreateAd
    extends UseCase<Either<Failure, CreateAdResult>, CreateAdParams> {
  CreateAd(this.repository);

  final ListingRepository repository;

  @override
  Future<Either<Failure, CreateAdResult>> call(CreateAdParams params) {
    return repository.createAd(params);
  }
}
