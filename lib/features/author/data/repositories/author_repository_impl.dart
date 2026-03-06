import 'package:dio/dio.dart';
import 'package:uz_xarid/core/error/exceptions.dart';
import 'package:uz_xarid/features/author/data/datasources/author_api.dart';
import 'package:uz_xarid/features/author/domain/entities/author_entity.dart';
import 'package:uz_xarid/features/author/domain/repositories/author_repository.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  final AuthorApi remoteDataSource;

  AuthorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthorEntity> getAuthorAds({
    required int userId,
    required int page,
  }) async {
    try {
      final response = await remoteDataSource.getAuthorAds(userId, page);

      if (response.status && response.data.user != null) {
        final authorData = response.data;
        final user = authorData.user!;

        final adsList =
            authorData.results?.map((e) {
              return AdSimilarEntity(
                slug: e.slug,
                title: e.title,
                mainImage: e.mainImage,
                price: e.price,
                finalPrice: e.finalPrice,
                currency: e.currency,
                rating: e.rating,
                reviewCount: e.reviewCount,
              );
            }).toList() ??
            [];

        return AuthorEntity(
          id: user.id,
          firstName: user.firstName ?? '',
          lastName: user.lastName ?? '',
        
          phone: user.phone,
          avatar: user.avatar,
          dateJoined: user.dateJoined,
          totalAds: authorData.totalAds ?? 0,
          totalCommentsAuthor: authorData.totalCommentsAuthor ?? 0,
          averageRatingAuthor: authorData.averageRatingAuthor ?? 0.0,
          ads: adsList,
          currentPage: authorData.currentPage ?? 1,
          totalPages: authorData.totalPages ?? 1,
        );
      } else {
        throw ServerException(message: 'Muallif topilmadi');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server xatosi');
    }
  }
}
