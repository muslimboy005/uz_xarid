import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/profile/data/models/my_listing_item_dto.dart';

abstract class MyListingsRepository {
  /// status: active | pending | unpaid | inactive | rejected
  Future<Either<Failure, List<MyListingItemDto>>> getMyListings(
    String status,
  );
}
