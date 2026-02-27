// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _FavoritesApi implements FavoritesApi {
  _FavoritesApi(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://uzxarid.felixits.uz/api/v1/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<FavoritesToggleResponseDto> toggle(
      Map<String, dynamic> body) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = body;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(_dio.options, 'user-like/toggle/',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)));
    return FavoritesToggleResponseDto.fromJson(_result.data!);
  }

  @override
  Future<FavoritesListResponseDto> getList(int page, int pageSize) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'page_size': pageSize
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(_dio.options, 'user-like/',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)));
    return FavoritesListResponseDto.fromJson(_result.data!);
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) return dioBaseUrl;
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
