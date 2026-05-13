import 'package:dio/dio.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uzxarid/features/profile/domain/repositories/my_listings_repository.dart';

class MyListingsRepositoryImpl implements MyListingsRepository {
  MyListingsRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<Either<Failure, List<MyListingItemDto>>> getMyListings(
    String status,
  ) async {
    try {
      final response = await dio.get(
        ApiUrls.myListings,
        queryParameters: {'status': status},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Noto\'g\'ri javob'));
      }
      final parsed = MyListingsResponseDto.fromJson(data);
      if (!parsed.status) {
        return Left(ServerFailure(message: 'Ma\'lumot olinmadi'));
      }
      return Right(parsed.data.results);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data as Map)['message'] ??
                (e.response?.data as Map)['detail']
          : null;
      return Left(
        ServerFailure(message: msg?.toString() ?? e.message ?? 'Tarmoq xatosi'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAd(String slug) async {
    if (slug.isEmpty) {
      return Left(ServerFailure(message: 'Slug bo\'sh'));
    }
    try {
      await dio.delete('ad/$slug/');
      return Right(null);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data as Map)['message'] ??
                (e.response?.data as Map)['detail']
          : null;
      return Left(
        ServerFailure(message: msg?.toString() ?? e.message ?? 'Tarmoq xatosi'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
