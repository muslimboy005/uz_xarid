import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/usecases/usecase.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';
import 'package:uz_xarid/features/home/domain/repositories/home_repository.dart';

class GetHome extends UseCase<Either<Failure, HomeEntity>, HomeParams> {
  GetHome(this.repository);

  final HomeRepository repository;

  @override
  Future<Either<Failure, HomeEntity>> call(HomeParams params) {
    return repository.getHome(
      categoryType: params.categoryType,
      pageSize: params.pageSize,
      adType: params.adType,
    );
  }
}

class HomeParams {
  final String categoryType;
  final int pageSize;
  final String adType;

  const HomeParams({
    this.categoryType = 'Product',
    this.pageSize = 16,
    this.adType = 'Sell',
  });
}
