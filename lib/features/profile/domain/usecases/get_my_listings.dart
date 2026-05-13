import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uzxarid/features/profile/domain/repositories/my_listings_repository.dart';

class GetMyListings
    extends UseCase<Either<Failure, List<MyListingItemDto>>, String> {
  GetMyListings(this.repository);

  final MyListingsRepository repository;

  @override
  Future<Either<Failure, List<MyListingItemDto>>> call(String status) {
    return repository.getMyListings(status);
  }
}
