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
    try {
      final detailFuture = api.getAdDetail(slug);
      final similarFuture = api.getSimilar(slug);
      final results = await Future.wait([detailFuture, similarFuture]);
      final detailResponse = results[0] as AdDetailResponseDto;
      final similarResponse = results[1] as AdSimilarResponseDto;

      if (!detailResponse.status || detailResponse.data.slug.isEmpty) {
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
        categoryName: d.category?.name,
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
        userName: _userDisplayName(d.user),
        userAvatar: d.user?.avatar,
        userPhone: d.user?.phone,
        userDateJoined: d.user?.dateJoined,
        totalAds: d.user?.adCount ?? d.totalAds ?? 0,
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
      return Right(entity);
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Tarmoq xatosi';
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
}
