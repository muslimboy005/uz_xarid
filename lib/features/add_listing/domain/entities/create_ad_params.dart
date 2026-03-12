/// Form ma'lumotlari – e'lon yaratish/tahrirlash so'rovida yuboriladi.
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
    this.slug,
    this.existingMainImageUrl,
    this.existingImageUrls = const [],
    this.weight,
    this.width,
    this.length,
    this.height,
    this.dimensionUnit,
    this.weightUnit,
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
  /// Tahrirlash rejimida e'lon slug'i.
  final String? slug;
  /// Tahrirlashda mavjud asosiy rasm URL (o'zgartirilmaganda).
  final String? existingMainImageUrl;
  /// Tahrirlashda mavjud qo'shimcha rasm URL lar.
  final List<String> existingImageUrls;
  final String? weight;
  final String? width;
  final String? length;
  final String? height;
  final String? dimensionUnit;
  final String? weightUnit;
}
