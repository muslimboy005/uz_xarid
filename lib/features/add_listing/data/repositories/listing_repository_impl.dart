import 'package:dio/dio.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_result.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/size_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/repositories/listing_repository.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl({required this.api, required this.dio});

  final ListingApi api;
  final Dio dio;

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

  @override
  Future<Either<Failure, CreateAdResult>> createAd(CreateAdParams params) async {
    try {
      final formData = FormData.fromMap({
        'title': params.title,
        'title_en': params.titleEn,
        'title_ru': params.titleRu,
        'description': params.description,
        'description_en': params.descriptionEn,
        'description_ru': params.descriptionRu,
        'ad_type': params.adType,
        'listing_type': params.listingType,
        'category': params.categoryId,
        'price': params.price,
        'currency': params.currency.toLowerCase(),
      });

      if (params.mainImagePath != null && params.mainImagePath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'main_image',
            await MultipartFile.fromFile(
              params.mainImagePath!,
              filename: params.mainImagePath!.split('/').last,
            ),
          ),
        );
      }
      for (final path in params.additionalImagePaths) {
        if (path.isEmpty) continue;
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        ApiUrls.ad,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'Noto\'g\'ri javob'));
      }
      final status = data['status'] as bool? ?? false;
      final resultData = data['data'];
      if (!status || resultData is! Map<String, dynamic>) {
        return Left(ServerFailure(message: 'E\'lon yaratib bo\'lmadi'));
      }
      final slug = resultData['slug'] as String? ?? '';
      if (slug.isEmpty) {
        return Left(ServerFailure(message: 'Slug topilmadi'));
      }
      return Right(CreateAdResult(slug: slug));
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data as Map)['message'] ?? (e.response?.data as Map)['detail']
          : null;
      return Left(ServerFailure(
        message: msg?.toString() ?? e.message ?? 'Tarmoq xatosi',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
