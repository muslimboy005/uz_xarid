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
