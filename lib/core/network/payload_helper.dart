import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:uz_xarid/core/app_config.dart';

class PayloadHelper {
  final String masterSecret;

  PayloadHelper({String? master})
    : masterSecret = master ?? AppConfig.masterSecret;

  static final _rng = Random.secure();

  String _b64u(Uint8List bytes) =>
      base64UrlEncode(bytes).replaceAll('=', '');

  String _hex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  Uint8List _randomBytes(int length) => Uint8List.fromList(
        List<int>.generate(length, (_) => _rng.nextInt(256)),
      );

  String _uuidV4() {
    final b = _randomBytes(16);
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = _hex(b);
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// Recipe (mirrors the production web frontend):
  ///   message = nonce + ts + iv      (string concatenation)
  ///   mac     = HMAC_SHA256(masterSecret, utf8(message))  → lowercase hex
  Map<String, String> createPayload() {
    final nonce = _uuidV4();
    final iv = _b64u(_randomBytes(16));
    final ts =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toString();
    final message = '$nonce$ts$iv';
    final macBytes = Hmac(sha256, utf8.encode(masterSecret))
        .convert(utf8.encode(message))
        .bytes;

    return {
      'nonce': nonce,
      'iv': iv,
      'ts': ts,
      'mac': _hex(macBytes),
    };
  }

  String createPayloadJson() => jsonEncode(createPayload());
}
