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
    this.latitude,
    this.longitude,
    this.address,
    this.regionId,
    this.districtId,
    this.neighborhoodId,
    this.street,
    this.houseNumber,
    this.apartment,
    this.addressComment,
    this.dynamicFields = const {},
    this.brand,
    this.brandModel,
    this.vehicleDetail,
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
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? regionId;
  final int? districtId;
  final int? neighborhoodId;
  final String? street;
  final String? houseNumber;
  final String? apartment;
  final String? addressComment;
  /// `attributes[<name>]` sifatida yuboriladigan dinamik fieldlar.
  /// `vehicle_detail` ichiga ko'chgan kalitlar bu yerga kirmaydi.
  final Map<String, dynamic> dynamicFields;

  /// Auto uchun top-level `brand` (id string).
  final String? brand;

  /// Auto uchun top-level `brand_model` (id string).
  final String? brandModel;

  /// Auto uchun `vehicle_detail` JSON object (repository jsonEncode qiladi).
  final Map<String, dynamic>? vehicleDetail;
}
