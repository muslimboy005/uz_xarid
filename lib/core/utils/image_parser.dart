class ImageParser {
  const ImageParser._();

  /// Safely extracts an image URL from either a String or a Map with multiple sizes.
  static String? parse(dynamic jsonImage) {
    if (jsonImage == null) return null;
    if (jsonImage is String) return rewriteImageHost(jsonImage);
    if (jsonImage is Map) {
      final large = jsonImage['large']?.toString();
      final medium = jsonImage['medium']?.toString();
      final small = jsonImage['small']?.toString();
      final original = jsonImage['original']?.toString();

      return rewriteImageHost(large ?? medium ?? small ?? original);
    }
    return null;
  }
}

/// Backend api-minio.upgroup.uz hostidan rasm yuboradi, lekin mobile mob-minio.uzxarid.uz
/// orqali olishi kerak. Shu yerda yagona joyda almashtiramiz.
const String _legacyImageHost = 'api-minio.upgroup.uz';
const String _imageHost = 'mob-minio.uzxarid.uz';

String? rewriteImageHost(String? url) {
  if (url == null || url.isEmpty) return url;
  if (!url.contains(_legacyImageHost)) return url;
  return url.replaceAll(_legacyImageHost, _imageHost);
}

/// `url.cdnUrl` — har qanday rasm URL'ini mob CDN hostiga ko'chiradi.
/// CachedNetworkImage / NetworkImage'ga uzatishdan oldin ishlatish tavsiya etiladi.
extension ImageUrlX on String {
  String get cdnUrl => rewriteImageHost(this) ?? this;
}
