import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';
import 'package:uz_xarid/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.homeApi});

  final HomeApi homeApi;

  @override
  Future<Either<Failure, HomeEntity>> getHome({
    String categoryType = 'Product',
    int pageSize = 16,
    String adType = 'Sell',
  }) async {
    try {
      final categoriesResponse = await homeApi.getCategories(categoryType);
      final bannersResponse = await homeApi.getBanners();
      final recommendationsResponse = await homeApi.getRecommendations(
        pageSize,
        adType,
      );
      final giftsResponse = await homeApi.getGifts(pageSize);
      final servicesResponse = await homeApi.getServices(pageSize);

      final entity = HomeEntity(
        categories: categoriesResponse.data.results
            .map((e) => e.toHomeCategory())
            .toList(),
        banners: bannersResponse.data.results
            .map((e) => e.toHomeBanner())
            .toList(),
        recommendations: recommendationsResponse.data.results
            .map((e) => e.toHomeRecommendation())
            .toList(),
        gifts: giftsResponse.data.results
            .map((e) => e.toHomeRecommendation())
            .toList(),
        services: servicesResponse.data.results
            .map((e) => e.toHomeRecommendation())
            .toList(),
      );

      return Right(entity);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Network error';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
