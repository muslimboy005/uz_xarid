import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_keys.dart';

enum AppMode { selling, buying }

class AppModeCubit extends Cubit<AppMode> {
  AppModeCubit() : super(AppMode.selling);

  /// Saqlangan rejimni yuklaydi (ilova qayta ochilganda yoki hot restart).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppKeys.appModeKey);
    if (saved == 'buying') {
      emit(AppMode.buying);
    } else if (saved == 'selling') {
      emit(AppMode.selling);
    }
  }

  Future<void> setSelling() async {
    emit(AppMode.selling);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.appModeKey, 'selling');
  }

  Future<void> setBuying() async {
    emit(AppMode.buying);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.appModeKey, 'buying');
  }

  void toggle() =>
      state == AppMode.selling ? setBuying() : setSelling();
}

extension AppModeColor on AppMode {
  /// Sotaman = ko'k primary, Sotib olaman = olovrang primary
  Color get primaryColor {
    switch (this) {
      case AppMode.selling:
        return AppColors.primary;
      case AppMode.buying:
        return AppColors.primaryBuying;
    }
  }

  /// AppBar rangi — selling=ko'k (primary), buying=toq olovrang
  Color get appBarColor {
    switch (this) {
      case AppMode.selling:
        return AppColors.primary;
      case AppMode.buying:
        return AppColors.primaryBuyingAppBar;
    }
  }

  Color get onAppBarColor {
    switch (this) {
      case AppMode.selling:
      case AppMode.buying:
        return Colors.white;
    }
  }
}
