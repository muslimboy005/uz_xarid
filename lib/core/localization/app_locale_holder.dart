import 'package:shared_preferences/shared_preferences.dart';

import 'package:uzxarid/core/constants/app_keys.dart';

/// Joriy ilova tili — API so'rovlarida Accept-Language header uchun.
/// LocaleCubit load/change da yangilaydi; Dio interceptor har so'rovda o'qiydi.
class AppLocaleHolder {
  AppLocaleHolder(this._prefs) {
    _languageCode = _prefs.getString(AppKeys.languageKey) ?? 'uz';
  }

  final SharedPreferences _prefs;
  String _languageCode = 'uz';

  String get languageCode => _languageCode;

  void setLanguageCode(String code) {
    if (_languageCode == code) return;
    _languageCode = code;
  }
}
