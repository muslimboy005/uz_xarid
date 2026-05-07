/// Narxni ekranga chiqarish uchun formatlovchi.
///
/// Butun qism 3 xonali bo'lib bo'shliq bilan ajratiladi (1 000 000).
/// Kasr qism saqlanadi, lekin oxiridagi ortiqcha nollar tashlanadi
/// (masalan, 1000.50 -> 1 000.5, 1000.00 -> 1 000, 0.87 -> 0.87).
String formatPrice(String? value) {
  if (value == null || value.isEmpty) return '';

  final cleaned = value.trim();
  final dotIndex = cleaned.indexOf('.');
  final intPart = dotIndex == -1 ? cleaned : cleaned.substring(0, dotIndex);
  var fracPart = dotIndex == -1 ? '' : cleaned.substring(dotIndex + 1);

  while (fracPart.isNotEmpty && fracPart.endsWith('0')) {
    fracPart = fracPart.substring(0, fracPart.length - 1);
  }

  final buf = StringBuffer();
  var count = 0;
  for (var i = intPart.length - 1; i >= 0; i--) {
    buf.write(intPart[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write(' ');
  }
  final formattedInt = buf.toString().split('').reversed.join();

  return fracPart.isEmpty ? formattedInt : '$formattedInt.$fracPart';
}
