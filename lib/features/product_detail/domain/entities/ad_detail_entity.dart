import 'package:equatable/equatable.dart';

/// Mahsulot / e'lon batafsil (product detail) entity.
class AdDetailEntity extends Equatable {
  const AdDetailEntity({
    required this.slug,
    required this.title,
    this.categoryId,
    this.categoryName,
    this.adType,
    this.listingType,
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
    this.weight,
    this.width,
    this.length,
    this.height,
    this.dimensionUnit,
    this.weightUnit,
    this.options = const [],
    this.images = const [],
    this.colors = const [],
    this.sizes = const [],
    this.attributes = const [],
    this.similar = const [],
    this.latitude,
    this.longitude,
    this.address,
  });

  final String slug;
  final String title;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? adType;
  final String? listingType;
  final String? price;
  final String? finalPrice;
  final String? discount;
  final String? mainImage;
  final String? currency;
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
  final num? weight;
  final num? width;
  final num? length;
  final num? height;
  final String? dimensionUnit;
  final String? weightUnit;
  final List<AdOptionEntity> options;
  final List<String> images;
  final List<AdColorEntity> colors;
  final List<AdSizeEntity> sizes;
  /// Avto / mototexnika: MARKA, MODEL, PROBEG va hokazo (API `attributes`).
  final List<AdAttributeEntity> attributes;
  final List<AdSimilarEntity> similar;
  final double? latitude;
  final double? longitude;
  final String? address;

  @override
  List<Object?> get props => [
    slug,
    title,
    categoryId,
    categoryName,
    adType,
    listingType,
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
    weight,
    width,
    length,
    height,
    dimensionUnit,
    weightUnit,
    options,
    images,
    colors,
    sizes,
    attributes,
    similar,
    latitude,
    longitude,
    address,
  ];
}

class AdOptionEntity extends Equatable {
  const AdOptionEntity({required this.name, required this.value});

  final String name;
  final String value;

  @override
  List<Object?> get props => [name, value];
}

class AdAttributeEntity extends Equatable {
  const AdAttributeEntity({required this.label, required this.value});

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
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
