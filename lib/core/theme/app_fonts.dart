import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();
  static const String manropeRegular = 'Manrope-Regular';
  static const String manropeMedium = 'Manrope-Medium';
  static const String manropeSemiBold = 'Manrope-SemiBold';
  static const String manropeBold = 'Manrope-bold';
  static const String manropeExtraBold = 'Manrope-ExtraBold';
  static const String manropeHeavy = 'Manrope-Heavy';

  static String getFontFamily(int? weight) {
    switch (weight) {
      case 400:
        return manropeRegular;
      case 500:
        return manropeMedium;
      case 600:
        return manropeSemiBold;
      case 700:
        return manropeBold;
      case 800:
        return manropeExtraBold;
      case 900:
        return manropeHeavy;
      default:
        return manropeRegular;
    }
  }

  static FontWeight? getFontWeight(int? weight) {
    switch (weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return null;
    }
  }
}
