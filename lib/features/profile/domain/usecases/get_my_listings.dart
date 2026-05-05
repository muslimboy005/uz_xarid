import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uz_xarid/features/profile/domain/repositories/my_listings_repository.dart';

class GetMyListings
    extends UseCase<Either<Failure, List<MyListingItemDto>>, String> {
  GetMyListings(this.repository);

  final MyListingsRepository repository;

  @override
  Future<Either<Failure, List<MyListingItemDto>>> call(String status) {
    return repository.getMyListings(status);
  }
}
