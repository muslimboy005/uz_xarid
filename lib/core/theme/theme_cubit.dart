import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uz_xarid/core/constants/app_keys.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  static const String _valueLight = 'light';
  static const String _valueDark = 'dark';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppKeys.themeModeKey);
    if (saved == _valueDark) {
      emit(ThemeMode.dark);
    } else if (saved == _valueLight) {
      emit(ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString(AppKeys.themeModeKey, _valueDark);
    } else {
      await prefs.setString(AppKeys.themeModeKey, _valueLight);
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
