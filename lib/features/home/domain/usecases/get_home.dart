import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';
import 'package:uzxarid/features/home/domain/repositories/home_repository.dart';

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
