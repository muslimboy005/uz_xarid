class HomeCategory {
  final int id;
  final String name;
  final String? image;

  const HomeCategory({
    required this.id,
    required this.name,
    this.image,
  });
}

class HomeBanner {
  final int id;
  final String title;
  final String? description;
  final String? mobileImage;
  final String? desktopImage;
  final String? link;
  final String? textColor;
  final String? backgroundColor;

  const HomeBanner({
    required this.id,
    required this.title,
    this.description,
    this.mobileImage,
    this.desktopImage,
    this.link,
    this.textColor,
    this.backgroundColor,
  });
}

class HomeRecommendation {
  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final bool isTop;

  const HomeRecommendation({
    required this.slug,
    required this.title,
    required this.currency,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.isTop = false,
  });
}

class HomeEntity {
  final List<HomeCategory> categories;
  final List<HomeBanner> banners;
  final List<HomeRecommendation> recommendations;
  final List<HomeRecommendation> gifts;
  final List<HomeRecommendation> services;

  const HomeEntity({
    required this.categories,
    required this.banners,
    required this.recommendations,
    required this.gifts,
    required this.services,
  });
}
