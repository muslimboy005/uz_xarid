import 'package:dio/dio.dart';

import 'package:uzxarid/core/localization/app_locale_holder.dart';

/// Har bir API so'roviga tanlangan ilova tilini Accept-Language sarlavhasida qo'shadi
/// (vebda bo'lgani kabi mobil da ham backend tilga qarab javob qaytaradi).
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._localeHolder);

  final AppLocaleHolder _localeHolder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final current = _localeHolder.languageCode.toLowerCase();
    const supported = ['uz', 'ru', 'en'];
    final ordered = <String>[current, ...supported.where((e) => e != current)];
    options.headers['Accept-Language'] = ordered.join(', ');
    handler.next(options);
  }
}
