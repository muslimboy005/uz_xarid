import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';

enum AppMode { selling, buying }

class AppModeCubit extends Cubit<AppMode> {
  AppModeCubit() : super(AppMode.selling);

  void setSelling() => emit(AppMode.selling);
  void setBuying() => emit(AppMode.buying);
  void toggle() =>
      emit(state == AppMode.selling ? AppMode.buying : AppMode.selling);
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
