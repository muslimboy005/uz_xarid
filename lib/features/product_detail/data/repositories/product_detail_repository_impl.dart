import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/features/product_detail/data/datasources/product_detail_api.dart';
import 'package:uz_xarid/features/product_detail/data/models/ad_detail_dto.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/product_detail/domain/repositories/product_detail_repository.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  ProductDetailRepositoryImpl({required this.api});

  final ProductDetailApi api;

  @override
  Future<Either<Failure, AdDetailEntity>> getAdDetail(String slug) async {
    developer.log('ProductDetailRepo: getAdDetail slug=$slug', name: 'ProductDetailRepo');
    try {
      final detailFuture = api.getAdDetail(slug);
      final similarFuture = api.getSimilar(slug);

      final results = await Future.wait([detailFuture, similarFuture]);
      final detailResponse = results[0] as AdDetailResponseDto;
      final similarResponse = results[1] as AdSimilarResponseDto;

      developer.log(
        'ProductDetailRepo: getAdDetail response status=${detailResponse.status}, '
        'slug=${detailResponse.data.slug}, title=${detailResponse.data.title}',
        name: 'ProductDetailRepo',
      );

      if (!detailResponse.status || detailResponse.data.slug.isEmpty) {
        developer.log('ProductDetailRepo: getAdDetail invalid response', name: 'ProductDetailRepo');
        return Left(ServerFailure(message: 'Ma\'lumot topilmadi'));
      }

      final d = detailResponse.data;
      final similarList =
          similarResponse.data.results
              ?.map(
                (e) => AdSimilarEntity(
                  slug: e.slug,
                  title: e.title,
                  mainImage: e.mainImage,
                  price: e.price,
                  finalPrice: e.finalPrice,
                  currency: e.currency,
                  rating: e.rating,
                  reviewCount: e.reviewCount,
                ),
              )
              .toList() ??
          [];

      final entity = AdDetailEntity(
        slug: d.slug,
        title: d.title,
        categoryId: d.category?.id,
        categoryName: d.category?.name,
        adType: d.adType,
        listingType: d.listingType,
        price: d.price,
        finalPrice: d.finalPrice,
        discount: d.discount,
        mainImage: d.mainImage,
        currency: d.currency ?? 'uzs',
        description: d.description,
        rating: d.rating ?? d.averageRating,
        reviewCount: d.reviewCount ?? d.totalComments ?? 0,
        likesCount: d.likesCount ?? 0,
        isLikes: d.isLikes,
        viewsCount: d.viewsCount ?? 0,
        callCount: d.callCount ?? 0,
        userId: d.user?.id,
        userName: _userDisplayName(d.user),
        userAvatar: d.user?.avatar,
        userPhone: d.user?.phone,
        userDateJoined: d.user?.dateJoined,
        totalAds: d.user?.adCount ?? d.totalAds ?? 0,
        weight: d.weight,
        width: d.width,
        length: d.length,
        height: d.height,
        dimensionUnit: d.dimensionUnit,
        weightUnit: d.weightUnit,
        options: (d.options ?? [])
            .map((e) => AdOptionEntity(name: e.name, value: e.value))
            .toList(),
        images: [
          if (d.mainImage != null && d.mainImage!.isNotEmpty) d.mainImage!,
          ...(d.images ?? []).map((e) => e.image),
        ],
        colors: (d.colors ?? [])
            .map(
              (e) => AdColorEntity(id: e.id, name: e.name, colorHex: e.color),
            )
            .toList(),
        sizes: (d.sizes ?? []).map((e) {
          final available = (d.variants ?? []).any(
            (v) => v.size?.id == e.id && (v.isAvailable ?? true),
          );
          return AdSizeEntity(
            id: e.id,
            name: e.name,
            isAvailable: (d.variants?.isEmpty ?? true) ? true : available,
          );
        }).toList(),
        similar: similarList,
      );
      developer.log('ProductDetailRepo: getAdDetail success entity.slug=${entity.slug}', name: 'ProductDetailRepo');
      return Right(entity);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      developer.log(
        'ProductDetailRepo: getAdDetail DioException slug=$slug, statusCode=$statusCode, message=$message, data=$responseData',
        name: 'ProductDetailRepo',
      );
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String? _userDisplayName(AdUserDto? user) {
    if (user == null) return null;
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    if (first.isNotEmpty || last.isNotEmpty) {
      return [first, last].where((s) => s.isNotEmpty).join(' ');
    }
    return user.username;
  }

  @override
  Future<Either<Failure, dynamic>> getFeedbacks(String slug) async {
    try {
      final response = await api.getFeedbacks(slug);
      return Right(response);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> leaveFeedback(
    String slug,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await api.leaveFeedback(slug, data);
      return Right(response);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
