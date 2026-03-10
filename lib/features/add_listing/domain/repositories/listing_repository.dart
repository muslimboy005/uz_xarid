import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_result.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';

abstract class ListingRepository {
  Future<Either<Failure, List<ColorEntity>>> getColors({int pageSize = 999});
  Future<Either<Failure, List<SizeEntity>>> getSizes({int pageSize = 999});
  Future<Either<Failure, CreateAdResult>> createAd(CreateAdParams params);
}
