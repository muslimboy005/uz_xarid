import 'package:flutter/services.dart';

class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Faqat raqamlarni olamiz
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 998 ni olib tashlaymiz agar boshida bo'lsa
    if (digits.startsWith('998')) {
      digits = digits.substring(3);
    }

    // Max 9 ta raqam (998 dan keyin)
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    // Agar bo'sh bo'lsa
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format: +998 XX XXX-XX-XX
    final buffer = StringBuffer('+998 ');

    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(' ');
      if (i == 5) buffer.write('-');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final last4 = digits.substring(digits.length - 4);
  return '(**$last4)';
}

/// Butun raqamlardan iborat satrni har 3 xona bo‘shliq bilan formatlaydi
/// (masalan, "38000" -> "38 000"). Raqam bo‘lmagan belgilarni e'tiborsiz qoldiradi.
String formatThousands(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  final buf = StringBuffer();
  var count = 0;
  for (var i = digits.length - 1; i >= 0; i--) {
    buf.write(digits[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write(' ');
  }
  return buf.toString().split('').reversed.join();
}

/// `formatThousands` natijasidan sof raqamlar satrini qaytaradi.
String stripThousandsSpaces(String value) =>
    value.replaceAll(RegExp(r'\s+'), '');

/// Real vaqtda butun sonlarni 3 xonali bo‘shliq bilan formatlovchi
/// `TextInputFormatter` (narx, probeg va shu kabi maydonlar uchun).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.maxValue});

  /// Agar berilgan bo‘lsa, ushbu qiymatdan oshib ketgan kiritma kesiladi.
  final int? maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (maxValue != null) {
      final parsed = int.tryParse(digits) ?? 0;
      if (parsed > maxValue!) digits = maxValue!.toString();
    }
    final formatted = formatThousands(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Xom telefon raqamini "+998 XX XXX-XX-XX" formatiga keltiradi.
/// Servisdan kelgan raqam ("998901234567" yoki "+998901234567") ham,
/// 9 xonali lokal raqam ("901234567") ham mos formatga keltiriladi.
/// Format etib bo'lmasa — kiruvchi qiymat o'zgarmasdan qaytariladi.
String formatUzbekPhone(String raw) {
  if (raw.isEmpty) return raw;
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('998')) {
    digits = digits.substring(3);
  }
  if (digits.length > 9) digits = digits.substring(0, 9);
  if (digits.isEmpty) return raw;

  final buffer = StringBuffer('+998 ');
  for (var i = 0; i < digits.length; i++) {
    if (i == 2) buffer.write(' ');
    if (i == 5) buffer.write('-');
    if (i == 7) buffer.write('-');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
