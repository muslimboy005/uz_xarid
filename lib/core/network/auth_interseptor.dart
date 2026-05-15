import 'package:dio/dio.dart';
import 'package:uzxarid/core/network/payload_interceptor.dart';
import 'package:uzxarid/core/service/local_service.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/service/auth_action_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;

  static const _publicEndpoints = [
    'auth/send-code',
    'auth/confirm',
    'home/',
    'banners/',
    'categories/',
    'products/',
    'ads/',
    'search/',
  ];
  static const _refreshEndpoint = 'internal/auth/token/refresh/';

  bool _isRefreshing = false;
  bool _isAuthenticating = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  // Bu Dio faqat token refresh uchun, interceptorsiz
  late final Dio _refreshDio;

  // Bu Dio retry uchun — interceptorsiz lekin to'liq baseUrl bilan
  late final Dio _retryDio;

  AuthInterceptor(this.secureStorageService) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: 'https://api.uzxarid.uz/api/v1/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _retryDio = Dio(
      BaseOptions(
        baseUrl: 'https://api.uzxarid.uz/api/v1/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Refresh/retry Dio'lar ham har bir requestga yangi signed payload qo'shadi.
    _refreshDio.interceptors.add(PayloadInterceptor());
    _retryDio.interceptors.add(PayloadInterceptor());
  }

  bool _isPublic(String path) => _publicEndpoints.any((e) => path.contains(e));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorageService.getToken();

    final isChat = options.path.contains('chat/');
    final isCartWrite = options.path.contains('cart/') &&
        options.method.toUpperCase() != 'GET';
    final needsProactiveAuth = isChat || isCartWrite;

    if (needsProactiveAuth && (token == null || token.isEmpty)) {
      final success = await getIt<AuthActionService>().ensureAuthenticated();
      if (success) {
        final newToken = await secureStorageService.getToken();
        if (newToken != null) {
          options.headers['Authorization'] = 'Bearer $newToken';
        }
        return handler.next(options);
      } else {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Authentication required',
          ),
        );
      }
    }

    if (!_isPublic(options.path) && options.headers['Authorization'] == null) {
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

    // Refresh endpointida 401 bo'lsa — refresh token ham eskirgan
    if (path.contains(_refreshEndpoint)) {
      _isRefreshing = false;
      await _handleUnauthorized(err, handler);
      return;
    }

    if (_isPublic(path)) {
      return handler.next(err);
    }

    final method = err.requestOptions.method.toUpperCase();
    final needsInteractiveAuth =
        path.contains('chat/') || (path.contains('cart/') && method != 'GET');

    // Allaqachon refresh qilinmoqda yoki login ko'rsatilmoqda — navbatga qo'shamiz
    if (_isRefreshing || _isAuthenticating) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await secureStorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        if (needsInteractiveAuth) {
          await _handleUnauthorized(err, handler);
        } else {
          await secureStorageService.clearAll();
          return handler.next(err);
        }
        return;
      }

      final response = await _refreshDio.post(
        _refreshEndpoint,
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        _isRefreshing = false;
        if (needsInteractiveAuth) {
          await _handleUnauthorized(err, handler);
        } else {
          await secureStorageService.clearAll();
          return handler.next(err);
        }
        return;
      }

      // Yangi tokenni saqlash
      await secureStorageService.saveToken(newAccess);

      // _isRefreshing ni pending'larni retry qilishdan OLDIN false qilamiz
      _isRefreshing = false;

      // Navbatdagi requestlarni yangilangan token bilan retry qilish
      _retryAll(newAccess);

      // Hozirgi requestni retry qilish
      final retried = await _retry(err.requestOptions, newAccess);
      return handler.resolve(retried);
    } catch (_) {
      _isRefreshing = false;
      if (needsInteractiveAuth) {
        await _handleUnauthorized(err, handler);
      } else {
        await secureStorageService.clearAll();
        return handler.next(err);
      }
    }
  }

  Future<void> _handleUnauthorized(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isAuthenticating) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isAuthenticating = true;
    _pendingRequests.add((options: err.requestOptions, handler: handler));

    final success = await getIt<AuthActionService>().ensureAuthenticated();

    if (success) {
      final newToken = await secureStorageService.getToken();
      if (newToken != null) {
        _isAuthenticating = false;
        _retryAll(newToken);
      } else {
        _isAuthenticating = false;
        _rejectAll(err);
      }
    } else {
      _isAuthenticating = false;
      _rejectAll(err);
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String newToken,
  ) async {
    // Yangi token bilan headerlarni to'liq o'rnatamiz
    final headers = Map<String, dynamic>.from(options.headers);
    headers['Authorization'] = 'Bearer $newToken';

    return _retryDio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: headers,
        contentType: options.contentType,
        responseType: options.responseType,
      ),
    );
  }

  void _retryAll(String newToken) {
    final pending = List.of(_pendingRequests);
    _pendingRequests.clear();
    for (final req in pending) {
      _retry(req.options, newToken).then(
        (res) => req.handler.resolve(res),
        onError: (e) => req.handler.next(
          DioException(requestOptions: req.options, error: e),
        ),
      );
    }
  }

  void _rejectAll(DioException err) {
    final pending = List.of(_pendingRequests);
    _pendingRequests.clear();
    for (final req in pending) {
      req.handler.next(
        DioException(
          requestOptions: req.options,
          response: err.response,
          type: err.type,
          error: err.error,
        ),
      );
    }
  }
}
