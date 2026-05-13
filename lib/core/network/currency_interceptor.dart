import 'package:dio/dio.dart';

import 'package:uzxarid/core/localization/currency_holder.dart';

/// Har bir API so'roviga tanlangan valyuta Ccy kodini x-currency sarlavhasida qo'shadi.
class CurrencyInterceptor extends Interceptor {
  CurrencyInterceptor(this._holder);

  final CurrencyHolder _holder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ccy = _holder.ccy;
    if (ccy.isNotEmpty) {
      options.headers['x-currency'] = ccy;
    }
    handler.next(options);
  }
}
