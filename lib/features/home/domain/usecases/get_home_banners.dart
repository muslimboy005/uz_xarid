import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/home/domain/entities/banner_entity.dart';
import 'package:uz_xarid/features/home/domain/repositories/home_banner_repository.dart';

class GetHomeBanners
    extends UseCase<Either<Failure, List<BannerEntity>>, NoParams> {
  GetHomeBanners(this.repository);

  final HomeBannerRepository repository;

  @override
  Future<Either<Failure, List<BannerEntity>>> call(NoParams params) {
    return repository.getBanners();
  }
}
