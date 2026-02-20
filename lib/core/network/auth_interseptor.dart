import 'package:dio/dio.dart';
import 'package:uz_xarid/core/service/local_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;

  static const _publicEndpoints = ['auth/send-code', 'auth/confirm'];
  static const _refreshEndpoint = 'auth/token/refresh/';

  bool _isRefreshing = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  late final Dio _refreshDio;

  AuthInterceptor(this.secureStorageService) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: 'https://uzxarid.felixits.uz/api/v1/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  bool _isPublic(String path) => _publicEndpoints.any((e) => path.contains(e));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await secureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;

    if (path.contains(_refreshEndpoint) || _isPublic(path)) {
      await secureStorageService.clearAll();
      return handler.next(err);
    }

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await secureStorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await secureStorageService.clearAll();
        _rejectAll(err);
        return handler.next(err);
      }

      final response = await _refreshDio.post(
        _refreshEndpoint,
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        await secureStorageService.clearAll();
        _rejectAll(err);
        return handler.next(err);
      }

      await secureStorageService.saveToken(newAccess);

      _retryAll(newAccess);

      final retried = await _retry(err.requestOptions, newAccess);
      return handler.resolve(retried);
    } catch (_) {
      await secureStorageService.clearAll();
      _rejectAll(err);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String newToken,
  ) async {
    options.headers['Authorization'] = 'Bearer $newToken';
    return _refreshDio.fetch(options);
  }

  void _retryAll(String newToken) {
    for (final pending in _pendingRequests) {
      _retry(pending.options, newToken).then(
        (res) => pending.handler.resolve(res),
        onError: (e) => pending.handler.next(
          DioException(requestOptions: pending.options, error: e),
        ),
      );
    }
    _pendingRequests.clear();
  }

  void _rejectAll(DioException err) {
    for (final pending in _pendingRequests) {
      pending.handler.next(
        DioException(
          requestOptions: pending.options,
          response: err.response,
          type: err.type,
          error: err.error,
        ),
      );
    }
    _pendingRequests.clear();
  }
}
