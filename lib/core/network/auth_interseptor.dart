import 'package:dio/dio.dart';
import 'package:uz_xarid/core/service/local_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;

  static const _publicEndpoints = ['auth/send-code', 'auth/confirm'];
  static const _refreshEndpoint = 'auth/token/refresh/';

  bool _isRefreshing = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  // Bu Dio faqat token refresh uchun, interceptorsiz
  late final Dio _refreshDio;

  // Bu Dio retry uchun — interceptorsiz lekin to'liq baseUrl bilan
  late final Dio _retryDio;

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

    _retryDio = Dio(
      BaseOptions(
        baseUrl: 'https://uzxarid.felixits.uz/api/v1/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  bool _isPublic(String path) => _publicEndpoints.any((e) => path.contains(e));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Faqat options ga token qo'shilmagan bo'lsa qo'shamiz
    // (retry'da options.headers ga allaqachon yangi token bor bo'ladi)
    if (!_isPublic(options.path) && options.headers['Authorization'] == null) {
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

    // Refresh endpointida 401 bo'lsa — refresh token ham eskirgan
    if (path.contains(_refreshEndpoint) || _isPublic(path)) {
      await secureStorageService.clearAll();
      return handler.next(err);
    }

    // Allaqachon refresh qilinmoqda — navbatga qo'shamiz
    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await secureStorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
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
        _isRefreshing = false;
        await secureStorageService.clearAll();
        _rejectAll(err);
        return handler.next(err);
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
      await secureStorageService.clearAll();
      _rejectAll(err);
      return handler.next(err);
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
