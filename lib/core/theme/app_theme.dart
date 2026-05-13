import 'package:flutter/material.dart';

import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({Color? primary}) {
    final p = primary ?? AppColors.primary;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p,
        primary: p,
        secondary: AppColors.secondary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: AppDimens.fontMedium,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimens.radiusMedium), //jjgj
          ),
        ),
      ),
    ).copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark({Color? primary}) {
    final p = primary ?? AppColors.primary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: p,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
        error: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: AppDimens.fontMedium,
          color: AppColors.darkTextPrimary,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimens.radiusMedium),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
      ),
      dividerColor: AppColors.darkTextSecondary,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: p,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),
    ).copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
