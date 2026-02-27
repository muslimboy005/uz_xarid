import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/repositories/listing_repository.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl({required this.api});

  final ListingApi api;

  @override
  Future<Either<Failure, List<ColorEntity>>> getColors({
    int pageSize = 999,
  }) async {
    try {
      final response = await api.getColors(pageSize);
      final list =
          response.data.results.map((dto) => dto.toEntity()).toList();
      return Right(list);
    } on DioException catch (e) {
      final message =
          e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SizeEntity>>> getSizes({
    int pageSize = 999,
  }) async {
    try {
      final response = await api.getSizes(pageSize);
      final list =
          response.data.results.map((dto) => dto.toEntity()).toList();
      return Right(list);
    } on DioException catch (e) {
      final message =
          e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
