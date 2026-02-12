import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
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
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  Dio get dio => _dio;

  Future<Map<String, String>> _createHeaders({
    bool withToken = true,
    String? contentType,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': contentType ?? 'application/json; charset=UTF-8',
    };

    if (withToken) {
      final token = await GetIt.I<SecureStorageService>().getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<MainModel> get(
      String uri, {
        Map<String, dynamic>? queryParameters,
        CancelToken? cancelToken,
        bool withToken = true,
      }) async {
    final headers = await _createHeaders(withToken: withToken);
    return _request(
          () => _dio.get(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(headers: headers),
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
    final headers = await _createHeaders(
      withToken: withToken,
      contentType: contentType,
    );
    return _request(
          () => _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: Options(headers: headers),
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
    final headers = await _createHeaders(
      withToken: withToken,
      contentType: contentType,
    );
    return _request(
          () => _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: Options(headers: headers),
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
    final headers = await _createHeaders(
      withToken: withToken,
      contentType: contentType,
    );
    return _request(
          () => _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: Options(headers: headers),
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
    final headers = await _createHeaders(
      withToken: withToken,
      contentType: contentType,
    );
    return _request(
          () => _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(headers: headers),
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
        detail:
        data is Map<String, dynamic> ? data : {'description': e.message},
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