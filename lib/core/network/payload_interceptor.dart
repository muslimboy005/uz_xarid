import 'package:dio/dio.dart';
import 'package:uz_xarid/core/network/payload_helper.dart';

/// Signs every outbound request with the four `x-payload-*` headers the
/// backend verifies via the shared `PAYLOAD_MASTER_SECRET`.
class PayloadInterceptor extends Interceptor {
  PayloadInterceptor({PayloadHelper? helper})
    : _helper = helper ?? PayloadHelper();

  final PayloadHelper _helper;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final payload = _helper.createPayload();
    options.headers['X-Payload-Nonce'] = payload['nonce'];
    options.headers['X-Payload-IV'] = payload['iv'];
    options.headers['X-Payload-TS'] = payload['ts'];
    options.headers['X-Payload-MAC'] = payload['mac'];
    handler.next(options);
  }
}
