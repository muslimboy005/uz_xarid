// core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:uz_xarid/core/network/auth_interseptor.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import '../constants/api_urls.dart';
import 'main_model.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // ✅ BIRINCHI - Auth Interceptor
    _dio.interceptors.add(AuthInterceptor(GetIt.I<SecureStorageService>()));

    // IKKINCHI - Log Interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          enabled: true,
          printRequestHeaders: true,
          printRequestExtra: true,
          printResponseHeaders: true,
          printResponseData: false,
          //printResponseMessage: false,
        ),
      ),
    );
  }

  Dio get dio => _dio;

  Future<MainModel> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool withToken = true,
  }) async {
    return _request(
      () => _dio.get(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<MainModel> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool withToken = true,
    String? contentType,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<MainModel> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool withToken = true,
    String? contentType,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<MainModel> patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool withToken = true,
    String? contentType,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _request(
      () => _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<MainModel> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool withToken = true,
    String? contentType,
  }) async {
    return _request(
      () => _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<MainModel> _request(Future<Response> Function() call) async {
    try {
      final response = await call();
      return _analyseResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  MainModel _analyseResponse(Response response) {
    final data = response.data;

    return MainModel(
      ok: true,
      status: response.statusCode ?? 200,
      result: data,
      errorCode: null,
      detail: null,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  MainModel _handleError(Object e) {
    if (e is DioException) {
      final res = e.response;
      final data = res?.data;
      final isSuccess =
          (res?.statusCode ?? 0) >= 200 && (res?.statusCode ?? 0) <= 300;

      return MainModel(
        ok: isSuccess,
        status: res?.statusCode ?? 0,
        result: null,
        errorCode: null,
        detail: data is Map<String, dynamic>
            ? data
            : {'description': e.message},
        timestamp: DateTime.now().toIso8601String(),
      );
    }

    return MainModel(
      ok: false,
      status: 0,
      result: null,
      errorCode: 'unknown_error',
      detail: {'description': e.toString()},
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}
