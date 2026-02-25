import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uz_xarid/core/constants/app_keys.dart';

/// Manages current locale with persistence.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('uz'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppKeys.languageKey);
    if (code != null && code.isNotEmpty) {
      emit(Locale(code));
    }
  }

  Future<void> change(Locale locale) async {
    if (state == locale) return;
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.languageKey, locale.languageCode);
  }
}
