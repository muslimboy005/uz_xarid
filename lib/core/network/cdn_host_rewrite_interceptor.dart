import 'package:dio/dio.dart';
import 'package:uzxarid/core/utils/image_parser.dart';

/// Backend rasm/hujjat URL'larini `api-minio.upgroup.uz` hostidan
/// mobile CDN `mob-minio.uzxarid.uz` ga ko'chiradi. JSON javobni
/// rekursiv aylanib chiqib, mos keluvchi har bir string'ni almashtiradi.
class CdnHostRewriteInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.data = _rewrite(response.data);
    handler.next(response);
  }

  dynamic _rewrite(dynamic node) {
    if (node is String) {
      return rewriteImageHost(node) ?? node;
    }
    if (node is Map) {
      node.updateAll((_, value) => _rewrite(value));
      return node;
    }
    if (node is List) {
      for (var i = 0; i < node.length; i++) {
        node[i] = _rewrite(node[i]);
      }
      return node;
    }
    return node;
  }
}
