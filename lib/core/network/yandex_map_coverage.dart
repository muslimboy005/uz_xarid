import 'dart:convert';

import 'package:dio/dio.dart';

/// Yandex Maps [coverage v2](https://api-maps.yandex.ru/services/coverage/v2/) — JSONP javobdan `status` o‘qiladi.
/// Xatolikda `true` qaytadi (xarita baribir ochiladi).
Future<bool> fetchYandexMapCoverageSuccess({
  double longitude = 69.24735733,
  double latitude = 41.32178969,
  int zoom = 14,
}) async {
  try {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
        responseType: ResponseType.plain,
      ),
    );
    final r = await dio.get<String>(
      'https://api-maps.yandex.ru/services/coverage/v2/',
      queryParameters: {
        'l': 'map',
        'll': '$longitude,$latitude',
        'z': '$zoom',
        'lang': 'ru_RU',
      },
    );
    final text = r.data?.trim() ?? '';
    if (text.isEmpty) return true;
    final i = text.indexOf('{');
    final j = text.lastIndexOf('}');
    if (i < 0 || j <= i) return true;
    final map = jsonDecode(text.substring(i, j + 1)) as Map<String, dynamic>;
    return map['status'] == 'success';
  } catch (_) {
    return true;
  }
}
