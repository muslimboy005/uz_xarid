import 'package:equatable/equatable.dart';

/// Mahsulot / e'lon batafsil (product detail) entity.
class AdDetailEntity extends Equatable {
  const AdDetailEntity({
    required this.slug,
    required this.title,
    this.categoryName,
    this.price,
    this.finalPrice,
    this.discount,
    this.mainImage,
    this.currency,
    this.description,
    this.rating,
    this.reviewCount,
    this.likesCount,
    this.isLikes,
    this.viewsCount,
    this.callCount,
    this.userId,
    this.userName,
    this.userAvatar,
    this.userPhone,
    this.userDateJoined,
    this.totalAds,
    this.options = const [],
    this.images = const [],
    this.colors = const [],
    this.sizes = const [],
    this.similar = const [],
  });

  final String slug;
  final String title;
  final String? categoryName;
  final String? price;
  final String? finalPrice;
  final String? discount;
  final String? mainImage;
  final String? currency;
  final String? description;
  final double? rating;
  final int? reviewCount;
  final int? likesCount;
  final bool? isLikes;
  final int? viewsCount;
  final int? callCount;
  final int? userId;
  final String? userName;
  final String? userAvatar;
  final String? userPhone;
  final String? userDateJoined;
  final int? totalAds;
  final List<AdOptionEntity> options;
  final List<String> images;
  final List<AdColorEntity> colors;
  final List<AdSizeEntity> sizes;
  final List<AdSimilarEntity> similar;

  @override
  List<Object?> get props => [
    slug,
    title,
    categoryName,
    price,
    finalPrice,
    mainImage,
    currency,
    description,
    rating,
    reviewCount,
    likesCount,
    isLikes,
    viewsCount,
    callCount,
    userId,
    userName,
    userAvatar,
    userPhone,
    userDateJoined,
    totalAds,
    options,
    images,
    colors,
    sizes,
    similar,
  ];
}

class AdOptionEntity extends Equatable {
  const AdOptionEntity({required this.name, required this.value});

  final String name;
  final String value;

  @override
  List<Object?> get props => [name, value];
}

class AdColorEntity extends Equatable {
  const AdColorEntity({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final int id;
  final String name;
  final String colorHex;

  @override
  List<Object?> get props => [id, name, colorHex];
}

class AdSizeEntity extends Equatable {
  const AdSizeEntity({
    required this.id,
    required this.name,
    this.isAvailable = true,
  });

  final int id;
  final String name;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, name, isAvailable];
}

class AdSimilarEntity extends Equatable {
  const AdSimilarEntity({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency,
    this.rating,
    this.reviewCount,
  });

  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String? currency;
  final double? rating;
  final int? reviewCount;

  @override
  List<Object?> get props => [
    slug,
    title,
    mainImage,
    price,
    finalPrice,
    currency,
    rating,
    reviewCount,
  ];
}
