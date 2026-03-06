import 'package:flutter/material.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';

/// Tema bo‘yicha fon/matn ranglari – statik rang qolmasligi uchun.
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bodyBackground =>
      isDark ? AppColors.darkBackground : AppColors.black50;

  Color get surfaceContainer => isDark ? AppColors.darkCard : AppColors.black50;

  Color get cardSurface => isDark ? AppColors.darkCard : AppColors.white;

  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textWhite => isDark ? AppColors.darkTextPrimary : AppColors.white;

  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get borderColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.cardBorderColor;
}
