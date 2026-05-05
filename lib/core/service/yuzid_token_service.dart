import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uz_xarid/core/config/yuzid_config.dart';

/// `POST /auth/get-token` — Basic Auth (login:parol).
class YuzIdTokenService {
  YuzIdTokenService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  final Dio _dio;

  Future<String> fetchToken({
    String? login,
    String? password,
    String? baseUrl,
  }) async {
    final user = login ?? YuzIdConfig.basicAuthLogin;
    final pass = password ?? YuzIdConfig.basicAuthPassword;
    final root = baseUrl ?? YuzIdConfig.apiBase;
    final basic = base64Encode(utf8.encode('$user:$pass'));
    final res = await _dio.post<Map<String, dynamic>>(
      '$root/auth/get-token',
      options: Options(headers: {'Authorization': 'Basic $basic'}),
    );
    final data = res.data;
    final token = data?['token'];
    if (token is! String || token.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'YuzID: javobda token yo‘q',
        response: res,
      );
    }
    return token;
  }
}
