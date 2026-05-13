import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/usecases/usecase.dart';
import 'package:uzxarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uzxarid/features/add_listing/domain/repositories/listing_repository.dart';

class GetColors
    extends UseCase<Either<Failure, List<ColorEntity>>, GetColorsParams> {
  GetColors(this.repository);

  final ListingRepository repository;

  @override
  Future<Either<Failure, List<ColorEntity>>> call(GetColorsParams params) {
    return repository.getColors(pageSize: params.pageSize);
  }
}

class GetColorsParams {
  const GetColorsParams({this.pageSize = 999});

  final int pageSize;
}
