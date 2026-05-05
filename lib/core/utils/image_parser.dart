class ImageParser {
  const ImageParser._();

  /// Safely extracts an image URL from either a String or a Map with multiple sizes.
  static String? parse(dynamic jsonImage) {
    if (jsonImage == null) return null;
    if (jsonImage is String) return jsonImage;
    if (jsonImage is Map) {
      final large = jsonImage['large']?.toString();
      final medium = jsonImage['medium']?.toString();
      final small = jsonImage['small']?.toString();
      final original = jsonImage['original']?.toString();

      return large ?? medium ?? small ?? original;
    }
    return null;
  }
}
