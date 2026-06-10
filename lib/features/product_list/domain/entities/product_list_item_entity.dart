/// Mahsulot ro'yxati elementining domain entity si.
class ProductListItemEntity {
  const ProductListItemEntity({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency = 'uzs',
    this.rating = 0,
    this.reviewCount = 0,
    this.categoryName,
    this.latitude,
    this.longitude,
  });

  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String? categoryName;

  /// E'lon joylashuvi (xaritada o'z koordinatasi ustida ko'rsatish uchun).
  final double? latitude;
  final double? longitude;

  /// Xaritada chizish uchun yaroqli koordinata bor-yo'qligi.
  bool get hasLocation => latitude != null && longitude != null;
}
