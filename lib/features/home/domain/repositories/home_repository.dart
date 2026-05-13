import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeEntity>> getHome({
    String categoryType,
    int pageSize,
    String adType,
  });
}
