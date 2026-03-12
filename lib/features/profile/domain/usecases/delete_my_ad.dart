import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/profile/domain/repositories/my_listings_repository.dart';

class DeleteMyAd extends UseCase<Either<Failure, void>, String> {
  DeleteMyAd(this.repository);

  final MyListingsRepository repository;

  @override
  Future<Either<Failure, void>> call(String slug) {
    return repository.deleteAd(slug);
  }
}
