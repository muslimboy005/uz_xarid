// core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:uz_xarid/core/service/local_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;

  AuthInterceptor(this.secureStorageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Public endpoint'lar (token kerak emas)
    final publicEndpoints = [
      'auth/send-code',
      'auth/confirm',
    ];

    // Agar public endpoint bo'lsa - skip
    final isPublicEndpoint = publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      // Token olish
      final token = await secureStorageService.getToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        print('✅ AuthInterceptor: Added token to ${options.path}');
        print('Token: ${token.substring(0, 30)}...');
      } else {
        print('⚠️ AuthInterceptor: No token for ${options.path}');
      }
    } else {
      print('ℹ️ AuthInterceptor: Public endpoint ${options.path}');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ Response: ${response.statusCode} - ${response.requestOptions.path}');
    return handler.next(response);
  }

 // AuthInterceptor'da onError:

@override
void onError(DioException err, ErrorInterceptorHandler handler) {
  if (err.response?.statusCode == 401) {
    final responseData = err.response?.data;
    final isTokenExpired = responseData is Map &&
        responseData['data']?['code'] == 'token_not_valid';

    if (isTokenExpired) {
      // Token expired - storage'ni tozalaymiz
      secureStorageService.clearAll().then((_) {
        print('✅ Expired token cleared');
      });
    }
  }

  return handler.next(err);
}
}