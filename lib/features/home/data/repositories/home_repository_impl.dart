import 'package:dio/dio.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/home/data/datasources/home_api.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';
import 'package:uzxarid/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.homeApi});

  final HomeApi homeApi;

  @override
  Future<Either<Failure, HomeEntity>> getHome({
    String categoryType = 'Product',
    int pageSize = 10,
    String adType = 'Sell',
  }) async {
    try {
      // HomePage faqat recommendations/gifts/services'ni ko'rsatadi; yuqoridagi
      // kategoriya plitkalari lokal (hardcoded). Banner ham UI'da chizilmaydi.
      // Shuning uchun `category/` va `banner/` so'rovlari yuborilmaydi.
      final recommendationsResponse = await homeApi.getRecommendations(
        pageSize,
        adType,
      );
      final giftsResponse = await homeApi.getGifts(pageSize);
      final servicesResponse = await homeApi.getServices(pageSize);

      final entity = HomeEntity(
        categories: const [],
        categoryIdToChildren: const {},
        banners: const [],
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
