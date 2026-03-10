/// Form ma'lumotlari – e'lon yaratish so'rovida yuboriladi.
class CreateAdParams {
  CreateAdParams({
    required this.title,
    required this.titleEn,
    required this.titleRu,
    required this.description,
    required this.descriptionEn,
    required this.descriptionRu,
    required this.adType,
    required this.listingType,
    required this.categoryId,
    required this.price,
    required this.currency,
    this.mainImagePath,
    this.additionalImagePaths = const [],
  });

  final String title;
  final String titleEn;
  final String titleRu;
  final String description;
  final String descriptionEn;
  final String descriptionRu;
  final String adType;
  final String listingType;
  final int categoryId;
  final String price;
  final String currency;
  final String? mainImagePath;
  final List<String> additionalImagePaths;
}
