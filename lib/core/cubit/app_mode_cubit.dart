import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppMode { selling, buying }

class AppModeCubit extends Cubit<AppMode> {
  AppModeCubit() : super(AppMode.selling);

  void setSelling() => emit(AppMode.selling);
  void setBuying() => emit(AppMode.buying);
  void toggle() =>
      emit(state == AppMode.selling ? AppMode.buying : AppMode.selling);
}

extension AppModeColor on AppMode {
  /// AppBar blue fon rangi — selling=ko'k, buying=sariq
  Color get appBarColor {
    switch (this) {
      case AppMode.selling:
        return const Color(0xFF1565C0); // primary blue
      case AppMode.buying:
        return const Color(0xFFF9A825); // amber/yellow
    }
  }

  Color get onAppBarColor {
    switch (this) {
      case AppMode.selling:
        return Colors.white;
      case AppMode.buying:
        return Colors.black87;
    }
  }
}
