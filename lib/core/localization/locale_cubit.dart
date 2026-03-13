import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uz_xarid/core/constants/app_keys.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/localization/app_locale_holder.dart';

/// Manages current locale with persistence.
/// API so'rovlarida Accept-Language uchun [AppLocaleHolder] ni ham yangilaydi.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('uz'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppKeys.languageKey);
    if (code != null && code.isNotEmpty) {
      final locale = Locale(code);
      emit(locale);
      getIt<AppLocaleHolder>().setLanguageCode(code);
    }
  }

  Future<void> change(Locale locale) async {
    if (state == locale) return;
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.languageKey, locale.languageCode);
    getIt<AppLocaleHolder>().setLanguageCode(locale.languageCode);
  }
}
