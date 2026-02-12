import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/home/domain/entities/banner_entity.dart';

abstract class HomeBannerRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();
}
