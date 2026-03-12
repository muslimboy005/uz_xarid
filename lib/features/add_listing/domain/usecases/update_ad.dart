import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_result.dart';
import 'package:uz_xarid/features/add_listing/domain/repositories/listing_repository.dart';

class UpdateAdParams {
  const UpdateAdParams({required this.slug, required this.params});

  final String slug;
  final CreateAdParams params;
}

class UpdateAd {
  UpdateAd(this.repository);

  final ListingRepository repository;

  Future<Either<Failure, CreateAdResult>> call(UpdateAdParams p) {
    return repository.updateAd(p.slug, p.params);
  }
}
