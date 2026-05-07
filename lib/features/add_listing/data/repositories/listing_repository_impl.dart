import 'package:dio/dio.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uz_xarid/features/add_listing/data/models/location_place_dto.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/category_field_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/color_entity.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_params.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/create_ad_result.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/location_place_entity.dart';
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
      final list = response.data.results.map((dto) => dto.toEntity()).toList();
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
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
      final list = response.data.results.map((dto) => dto.toEntity()).toList();
      return Right(list);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<LocationPlaceEntity>>> _fetchAllPlaces(
    Future<LocationPagedResponseDto> Function(int page) fetchPage,
  ) async {
    try {
      final all = <LocationPlaceEntity>[];
      var page = 1;
      while (true) {
        final response = await fetchPage(page);
        if (!response.status) {
          return Left(ServerFailure(message: 'Ma\'lumot yuklanmadi'));
        }
        final data = response.data;
        for (final dto in data.results) {
          all.add(dto.toEntity());
        }
        if (page >= data.totalPages) break;
        page++;
      }
      all.sort((a, b) => a.name.compareTo(b.name));
      return Right(all);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocationPlaceEntity>>> getRegions() {
    return _fetchAllPlaces((p) => api.getRegions(p));
  }

  @override
  Future<Either<Failure, List<LocationPlaceEntity>>> getDistricts(
    int regionId,
  ) {
    return _fetchAllPlaces((p) => api.getDistricts(p, regionId));
  }

  @override
  Future<Either<Failure, List<LocationPlaceEntity>>> getNeighborhoods(
    int districtId,
  ) {
    return _fetchAllPlaces((p) => api.getNeighborhoods(p, districtId));
  }

  @override
  Future<Either<Failure, List<CategoryFieldEntity>>> getCategoryFields({
    required String listingType,
    int? categoryId,
  }) async {
    try {
      final response = await dio.get(
        ApiUrls.categoryFields,
        queryParameters: {
          'listing_type': listingType,
          'category_id': ?categoryId,
        },
      );
      final data = response.data;
      if (data is! Map) {
        return Left(ServerFailure(message: 'Noto\'g\'ri javob'));
      }
      final mapped = data.cast<String, dynamic>();
      final listRaw = mapped['data'];
      if (listRaw is! List) {
        return Right([]);
      }
      final result = <CategoryFieldEntity>[];
      for (final item in listRaw) {
        if (item is Map<String, dynamic>) {
          result.add(CategoryFieldEntity.fromJson(item));
        } else if (item is Map) {
          result.add(
            CategoryFieldEntity.fromJson(item.cast<String, dynamic>()),
          );
        }
      }
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: msg));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreateAdResult>> createAd(
    CreateAdParams params,
  ) async {
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
        if (params.latitude != null) 'latitude': params.latitude,
        if (params.longitude != null) 'longitude': params.longitude,
        if (params.regionId != null) 'region': params.regionId,
        if (params.districtId != null) 'district': params.districtId,
        if (params.neighborhoodId != null)
          'neighborhood': params.neighborhoodId,
        ...params.dynamicFields,
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
            await MultipartFile.fromFile(path, filename: path.split('/').last),
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
  Future<Either<Failure, CreateAdResult>> updateAd(
    String slug,
    CreateAdParams params,
  ) async {
    try {
      final hasNewImages =
          (params.mainImagePath != null && params.mainImagePath!.isNotEmpty) ||
          params.additionalImagePaths.isNotEmpty;

      if (hasNewImages) {
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
          if (params.weight != null && params.weight!.isNotEmpty)
            'weight': params.weight,
          if (params.width != null && params.width!.isNotEmpty)
            'width': params.width,
          if (params.length != null && params.length!.isNotEmpty)
            'length': params.length,
          if (params.height != null && params.height!.isNotEmpty)
            'height': params.height,
          if (params.dimensionUnit != null && params.dimensionUnit!.isNotEmpty)
            'dimension_unit': params.dimensionUnit!.toLowerCase(),
          if (params.weightUnit != null && params.weightUnit!.isNotEmpty)
            'weight_unit': params.weightUnit!.toLowerCase(),
          if (params.latitude != null) 'latitude': params.latitude,
          if (params.longitude != null) 'longitude': params.longitude,
          if (params.regionId != null) 'region': params.regionId,
          if (params.districtId != null) 'district': params.districtId,
          if (params.neighborhoodId != null)
            'neighborhood': params.neighborhoodId,
          ...params.dynamicFields,
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

        final response = await dio.put(
          '${ApiUrls.ad}$slug/',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        return _parseAdResponse(response, slug);
      }

      final body = <String, dynamic>{
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
        if (params.existingMainImageUrl != null &&
            params.existingMainImageUrl!.isNotEmpty)
          'main_image': params.existingMainImageUrl,
        if (params.existingImageUrls.isNotEmpty)
          'images': params.existingImageUrls,
        if (params.weight != null && params.weight!.isNotEmpty)
          'weight': params.weight,
        if (params.width != null && params.width!.isNotEmpty)
          'width': params.width,
        if (params.length != null && params.length!.isNotEmpty)
          'length': params.length,
        if (params.height != null && params.height!.isNotEmpty)
          'height': params.height,
        if (params.dimensionUnit != null && params.dimensionUnit!.isNotEmpty)
          'dimension_unit': params.dimensionUnit!.toLowerCase(),
        if (params.weightUnit != null && params.weightUnit!.isNotEmpty)
          'weight_unit': params.weightUnit!.toLowerCase(),
        if (params.latitude != null) 'latitude': params.latitude,
        if (params.longitude != null) 'longitude': params.longitude,
        if (params.address != null) 'address': params.address,
        if (params.regionId != null) 'region': params.regionId,
        if (params.districtId != null) 'district': params.districtId,
        if (params.neighborhoodId != null)
          'neighborhood': params.neighborhoodId,
        ...params.dynamicFields,
      };

      final response = await dio.put(
        '${ApiUrls.ad}$slug/',
        data: body,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return _parseAdResponse(response, slug);
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

  Either<Failure, CreateAdResult> _parseAdResponse(
    Response<dynamic> response,
    String slug,
  ) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return Left(ServerFailure(message: 'Noto\'g\'ri javob'));
    }
    final status = data['status'] as bool? ?? false;
    final resultData = data['data'];
    if (!status || resultData is! Map<String, dynamic>) {
      return Left(ServerFailure(message: 'E\'lon yangilanmadi'));
    }
    final resultSlug = resultData['slug'] as String? ?? slug;
    return Right(CreateAdResult(slug: resultSlug));
  }
}
