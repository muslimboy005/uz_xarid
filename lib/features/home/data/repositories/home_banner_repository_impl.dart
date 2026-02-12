import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/home/data/datasources/home_banner_api.dart';
import 'package:uz_xarid/features/home/domain/entities/banner_entity.dart';
import 'package:uz_xarid/features/home/domain/repositories/home_banner_repository.dart';

class HomeBannerRepositoryImpl implements HomeBannerRepository {
  HomeBannerRepositoryImpl(this.api);

  final HomeBannerApi api;

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final response = await api.getBanners();
      final entities = response.data.results.map((e) => e.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Network error';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
