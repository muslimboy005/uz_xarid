import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/profile/data/models/my_listing_item_dto.dart';

abstract class MyListingsRepository {
  /// status: active | pending | unpaid | inactive | rejected
  Future<Either<Failure, List<MyListingItemDto>>> getMyListings(String status);

  /// E'lonni slug orqali o'chirish. DELETE ad/{slug}/
  Future<Either<Failure, void>> deleteAd(String slug);
}
