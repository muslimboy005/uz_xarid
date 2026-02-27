import 'package:equatable/equatable.dart';

class FavoriteItemEntity extends Equatable {
  const FavoriteItemEntity({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency = 'uzs',
    this.rating = 0,
    this.reviewCount = 0,
    this.isLiked = true,
  });

  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final bool isLiked;

  @override
  List<Object?> get props =>
      [slug, title, mainImage, price, finalPrice, currency, rating, reviewCount, isLiked];
}
