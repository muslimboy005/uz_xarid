import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/profile/data/models/ad_limit_info_dto.dart';
import 'package:uzxarid/features/profile/domain/repositories/my_listings_repository.dart';

class GetAdLimitInfo
    extends UseCase<Either<Failure, AdLimitInfoDto>, NoParams> {
  GetAdLimitInfo(this.repository);

  final MyListingsRepository repository;

  @override
  Future<Either<Failure, AdLimitInfoDto>> call(NoParams params) {
    return repository.getLimitInfo();
  }
}
