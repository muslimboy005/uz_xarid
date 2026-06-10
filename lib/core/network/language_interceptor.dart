import 'package:dio/dio.dart';

import 'package:uzxarid/core/localization/app_locale_holder.dart';

/// Har bir API so'roviga tanlangan ilova tilini Accept-Language sarlavhasida qo'shadi
/// (vebda bo'lgani kabi mobil da ham backend tilga qarab javob qaytaradi).
///
/// Veb-klient faqat bitta — joriy tanlangan tilni yuboradi, shuning uchun
/// bu yerda ham ro'yxat emas, bitta til kodi yuboriladi.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._localeHolder);

  final AppLocaleHolder _localeHolder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _localeHolder.languageCode.toLowerCase();
    handler.next(options);
  }
}
