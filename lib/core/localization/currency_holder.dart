import 'package:shared_preferences/shared_preferences.dart';

import 'package:uz_xarid/core/constants/app_keys.dart';

/// Joriy tanlangan valyuta Ccy — har bir API so'rovida x-currency header uchun.
/// CurrencyCubit load/select da yangilaydi; Dio interceptor har so'rovda o'qiydi.
class CurrencyHolder {
  CurrencyHolder(this._prefs) {
    _ccy = _prefs.getString(AppKeys.selectedCurrencyKey) ?? 'UZS';
  }

  final SharedPreferences _prefs;
  String _ccy = 'UZS';

  String get ccy => _ccy;

  void setCcy(String ccy) {
    if (_ccy == ccy) return;
    _ccy = ccy;
  }
}
