import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soliq_id/localizations_util.dart';
import 'package:soliq_id/soliq_id.dart';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uzxarid/core/config/yuzid_config.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/service/yuzid_token_service.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:yuz_id/yuz_id.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class BirthDateFormatter extends TextInputFormatter {
  const BirthDateFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('.');
      }
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

bool _isValidBirthDate(String value) {
  if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value)) {
    return false;
  }

  final parts = value.split('.');
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) {
    return false;
  }
  if (year < 1900 || year > DateTime.now().year) {
    return false;
  }

  final parsed = DateTime.tryParse(
    '${year.toString().padLeft(4, '0')}-'
    '${month.toString().padLeft(2, '0')}-'
    '${day.toString().padLeft(2, '0')}',
  );
  return parsed != null &&
      parsed.year == year &&
      parsed.month == month &&
      parsed.day == day;
}

/// Passport ma'lumotlari — `SoliqId` vidjetiga uzatiladi.
class SoliqIdentityInput {
  const SoliqIdentityInput({
    required this.passportSeries,
    required this.passportNumber,
    required this.birthDate,
    required this.guid,
  });

  final String passportSeries;
  final String passportNumber;
  final String birthDate;
  final String guid;
}

/// Yuz skaneridan keyin natija.
class SoliqFaceScanResult {
  const SoliqFaceScanResult({required this.isSuccess, this.failureMessage});

  final bool isSuccess;
  final String? failureMessage;
}

/// Modal orqali foydalanuvchi ma'lumotlari va YuzID `guid` (token).
Future<SoliqIdentityInput?> showSoliqIdentityInputSheet(
  BuildContext context,
) async {
  String series = '';
  String number = '';
  String birthDate = '';
  var isSubmitting = false;

  return showModalBottomSheet<SoliqIdentityInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.cardSurface,
    builder: (ctx) {
      InputDecoration dec(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      );

      return StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "SoliqID (Yuz ID) ma'lumotlari",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tug\'ilgan sana: kun.oy.yil (masalan 01.05.1990)',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    const UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: (v) => series = v.trim().toUpperCase(),
                  decoration: dec('Passport seriyasi (masalan AA)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onChanged: (v) => number = v.trim(),
                  decoration: dec('Passport raqami'),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: const [BirthDateFormatter()],
                  onChanged: (v) => birthDate = v.trim(),
                  decoration: dec("Tug'ilgan sana (dd.MM.yyyy)"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (isSubmitting) return;
                          if (series.isEmpty ||
                              number.isEmpty ||
                              birthDate.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text("Barcha maydonlarni to'ldiring"),
                                backgroundColor: AppColors.red,
                              ),
                            );
                            return;
                          }
                          if (!RegExp(r'^[A-Z]{2}$').hasMatch(series)) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Passport seriyasi 2 ta katta harf bo'lishi kerak (masalan AA)",
                                ),
                                backgroundColor: AppColors.red,
                              ),
                            );
                            return;
                          }
                          if (!RegExp(r'^\d{7}$').hasMatch(number)) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Passport raqami 7 ta raqam bo'lishi kerak",
                                ),
                                backgroundColor: AppColors.red,
                              ),
                            );
                            return;
                          }
                          if (!_isValidBirthDate(birthDate)) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Sanani dd.MM.yyyy formatida kiriting (masalan 01.05.1990)",
                                ),
                                backgroundColor: AppColors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);
                          showDialog<void>(
                            context: ctx,
                            barrierDismissible: false,
                            builder: (dCtx) => const PopScope(
                              canPop: false,
                              child: Center(
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(28),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          );

                          String token;
                          try {
                            token = await YuzIdTokenService().fetchToken();
                          } catch (e) {
                            if (ctx.mounted) {
                              Navigator.of(ctx, rootNavigator: true).pop();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'YuzID token olinmadi: ${e.toString()}',
                                  ),
                                  backgroundColor: AppColors.red,
                                ),
                              );
                            }
                            if (ctx.mounted) {
                              setModalState(() => isSubmitting = false);
                            }
                            return;
                          }
                          if (!ctx.mounted) return;
                          Navigator.of(ctx, rootNavigator: true).pop();
                          Navigator.pop(
                            ctx,
                            SoliqIdentityInput(
                              passportSeries: series,
                              passportNumber: number,
                              birthDate: birthDate,
                              guid: token,
                            ),
                          );
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Davom etish'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// `SoliqId` ekranini ochadi; paket API si o‘zgartirilmagan.
Future<SoliqFaceScanResult> runSoliqIdFaceScan(
  BuildContext context, {
  required SoliqIdentityInput identity,
  LocalizationType localization = LocalizationType.UZ,
}) async {
  debugPrint(
    '[FACE_VERIFY] scan started passport=${identity.passportSeries}${identity.passportNumber}',
  );

  Map<String, dynamic>? scanResult;
  var eventCount = 0;

  dynamic routeResult;
  try {
    routeResult = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute<void>(
        builder: (_) => SoliqId(
          pinfl: '',
          infoType: InfoType.passport,
          passportSeries: identity.passportSeries,
          passportNumber: identity.passportNumber,
          birthDate: identity.birthDate,
          localizationType: localization,
          guid: identity.guid,
          applicationGuid: YuzIdConfig.applicationGuid,
          onNavigate: false,
          onEvent: (dynamic event) {
            eventCount++;
            debugPrint(
              '[FACE_VERIFY] onEvent#$eventCount type=${event.runtimeType} '
              'raw=${_preview(event)}',
            );
            final parsed = _parseDynamicPayload(event);
            if (parsed != null) {
              scanResult = parsed;
              final img = _extractFaceImage(scanResult);
              debugPrint(
                '[FACE_VERIFY] onEvent parsed success=${scanResult?['success']} '
                'message=${scanResult?['message']} '
                'imageLen=${img?.length ?? 0} '
                'imageHead=${_preview(img)}',
              );
            } else {
              debugPrint('[FACE_VERIFY] onEvent payload is not parseable');
            }
          },
        ),
      ),
    );
  } catch (e) {
    debugPrint('[FACE_VERIFY] SoliqId route error: $e');
    return SoliqFaceScanResult(
      isSuccess: false,
      failureMessage: e.toString(),
    );
  }
  debugPrint(
    '[FACE_VERIFY] route closed eventCount=$eventCount '
    'routeResultType=${routeResult.runtimeType} routeResult=${_preview(routeResult)}',
  );
  if (scanResult == null) {
    final parsedRoute = _parseDynamicPayload(routeResult);
    if (parsedRoute != null) {
      scanResult = parsedRoute;
      debugPrint('[FACE_VERIFY] using parsed routeResult as scanResult');
    }
  }

  if (scanResult == null) {
    debugPrint('[FACE_VERIFY] scanResult is null after SoliqId flow');
    return const SoliqFaceScanResult(
      isSuccess: false,
      failureMessage: 'Face ID natijasi olinmadi.',
    );
  }

  final ok = _isSuccessfulScan(scanResult);
  final imageBase64 = _extractFaceImage(scanResult);
  if (imageBase64 != null && imageBase64.isNotEmpty) {
    debugPrint(
      '[FACE_VERIFY] image found, backend verify will run '
      'pluginSuccess=$ok imageLen=${imageBase64.length}',
    );
    final verifyResult = await _verifyFaceWithBackend(
      identity: identity,
      imageBase64: imageBase64,
    );
    if (!verifyResult.isSuccess) {
      debugPrint(
        '[FACE_VERIFY] backend verify failed message=${verifyResult.message}',
      );
      return SoliqFaceScanResult(
        isSuccess: false,
        failureMessage: verifyResult.message,
      );
    }
    debugPrint('[FACE_VERIFY] backend verify success');
    return const SoliqFaceScanResult(isSuccess: true);
  }
  debugPrint(
    '[FACE_VERIFY] image missing in SoliqId result, trying direct YuzID fallback',
  );
  final directImage = await _runDirectYuzIdCapture(localization);
  if (directImage != null && directImage.isNotEmpty) {
    debugPrint(
      '[FACE_VERIFY] fallback direct YuzID image captured len=${directImage.length}',
    );
    final verifyResult = await _verifyFaceWithBackend(
      identity: identity,
      imageBase64: directImage,
    );
    if (!verifyResult.isSuccess) {
      debugPrint(
        '[FACE_VERIFY] fallback backend verify failed message=${verifyResult.message}',
      );
      return SoliqFaceScanResult(
        isSuccess: false,
        failureMessage: verifyResult.message,
      );
    }
    debugPrint('[FACE_VERIFY] fallback backend verify success');
    return const SoliqFaceScanResult(isSuccess: true);
  }
  if (ok) {
    debugPrint('[FACE_VERIFY] plugin success but image missing');
    return const SoliqFaceScanResult(
      isSuccess: false,
      failureMessage: 'Yuz rasmi olinmadi.',
    );
  }
  final msg = scanResult?['message'];
  final text = msg is String && msg.trim().isNotEmpty ? msg.trim() : null;
  debugPrint('[FACE_VERIFY] scan failed message=$text');
  return SoliqFaceScanResult(isSuccess: false, failureMessage: text);
}

Future<String?> _runDirectYuzIdCapture(LocalizationType localization) async {
  try {
    final lang = switch (localization) {
      LocalizationType.RU => 'ru',
      LocalizationType.UZ_KIRILL => 'uz',
      LocalizationType.KR => 'uz',
      LocalizationType.UZ => 'uz',
    };
    final image = await YuzID.instance.runYuzID(lang: lang);
    final normalized = image?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  } catch (e) {
    debugPrint('[FACE_VERIFY] direct YuzID error: $e');
    return null;
  }
}

String? _extractFaceImage(Map<String, dynamic>? payload) {
  if (payload == null) return null;

  return _extractFaceImageDynamic(payload);
}

Map<String, dynamic>? _parseDynamicPayload(dynamic payload) {
  if (payload == null) return null;

  if (payload is Map) {
    return _toStringKeyMap(payload);
  }

  if (payload is String) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return _toStringKeyMap(decoded);
    } catch (_) {
      return null;
    }
  }

  try {
    final dynamic rawJson = payload.toJson();
    if (rawJson is Map) return _toStringKeyMap(rawJson);
  } catch (_) {}

  try {
    final encoded = jsonEncode(payload);
    final decoded = jsonDecode(encoded);
    if (decoded is Map) return _toStringKeyMap(decoded);
  } catch (_) {}

  return null;
}

Map<String, dynamic> _toStringKeyMap(Map source) {
  final map = <String, dynamic>{};
  source.forEach((key, value) {
    final strKey = key.toString();
    if (value is Map) {
      map[strKey] = _toStringKeyMap(value);
    } else if (value is List) {
      map[strKey] = value.map(_normalizeDynamic).toList();
    } else {
      map[strKey] = value;
    }
  });
  return map;
}

dynamic _normalizeDynamic(dynamic value) {
  if (value is Map) return _toStringKeyMap(value);
  if (value is List) return value.map(_normalizeDynamic).toList();
  return value;
}

bool _isSuccessfulScan(Map<String, dynamic>? payload) {
  if (payload == null) return false;
  final successValue = payload['success'];
  if (successValue == true || successValue?.toString() == '1') {
    return true;
  }

  final status = payload['status']?.toString().toLowerCase();
  if (status == 'success' || status == 'ok') {
    return true;
  }

  final code = payload['code'];
  if (code == 1 || code?.toString() == '1') {
    return true;
  }

  final message = payload['message']?.toString().toLowerCase() ?? '';
  if (message.contains('muvaffaq') || message.contains('success')) {
    return true;
  }
  return false;
}

String? _extractFaceImageDynamic(dynamic payload) {
  if (payload == null) return null;

  if (payload is String) {
    final candidate = payload.trim();
    if (_looksLikeBase64Image(candidate)) return candidate;
    return null;
  }

  if (payload is List) {
    for (final item in payload) {
      final nested = _extractFaceImageDynamic(item);
      if (nested != null) return nested;
    }
    return null;
  }

  if (payload is Map) {
    const preferredKeys = [
      'image',
      'image_base64',
      'imageBase64',
      'face_image',
      'faceImage',
      'photo',
    ];

    for (final key in preferredKeys) {
      final value = payload[key];
      final nested = _extractFaceImageDynamic(value);
      if (nested != null) return nested;
    }

    for (final value in payload.values) {
      final nested = _extractFaceImageDynamic(value);
      if (nested != null) return nested;
    }
  }

  return null;
}

bool _looksLikeBase64Image(String value) {
  if (value.isEmpty) return false;
  if (value.startsWith('data:image/')) return true;
  if (value.length < 120) return false;
  final normalized = _normalizeBase64(value);
  return RegExp(r'^[A-Za-z0-9+/=\r\n]+$').hasMatch(normalized);
}

Future<_FaceVerifyResult> _verifyFaceWithBackend({
  required SoliqIdentityInput identity,
  required String imageBase64,
}) async {
  try {
    final normalizedBase64 = _normalizeBase64(imageBase64);
    debugPrint(
      '[FACE_VERIFY] request payload '
      'passport_series=${identity.passportSeries} '
      'passport_number=${identity.passportNumber} '
      'imageLen=${normalizedBase64.length} '
      'imageHead=${_preview(normalizedBase64)}',
    );
    final deviceId = await _getOrCreateDeviceId();
    debugPrint(
      '[FACE_VERIFY] using image_base64 only '
      'bytes=${normalizedBase64.length} '
      'device_id=$deviceId',
    );

    final dio = getIt<DioClient>().dio;
    final formData = FormData.fromMap({
      'passport_series': identity.passportSeries,
      'passport_number': identity.passportNumber,
      'image_base64': normalizedBase64,
      'device_id': deviceId,
    });

    final response = await dio.post(
      ApiUrls.faceVerificationVerify,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    debugPrint(
      '[FACE_VERIFY] response status=${response.statusCode} '
      'body=${_preview(response.data)}',
    );
    final data = response.data;
    if (data is! Map) {
      return const _FaceVerifyResult(
        isSuccess: false,
        message: 'Face verification javobi noto‘g‘ri formatda.',
      );
    }
    final map = _toStringKeyMap(data);
    final verified =
        _parseBool(map['verified']) == true &&
        _parseBool(map['is_face_verified']) == true;
    final statusOk =
        (map['status']?.toString().toLowerCase() ?? '') == 'success' ||
        (map['status']?.toString().toLowerCase() ?? '') == 'ok';
    final codeOk = map['code']?.toString() == '1';
    final hasFailureSignal = _parseBool(map['verified']) == false ||
        _parseBool(map['is_face_verified']) == false;
    final accepted = verified || (!hasFailureSignal && (statusOk || codeOk));
    if (!accepted) {
      debugPrint(
        '[FACE_VERIFY] response validation failed '
        'verified=${map['verified']} '
        'is_face_verified=${map['is_face_verified']} '
        'status=${map['status']} code=${map['code']} '
        'message=${map['message']} request_id=${map['request_id']}',
      );
      return _FaceVerifyResult(
        isSuccess: false,
        message: (map['message']?.toString().trim().isNotEmpty ?? false)
            ? map['message'].toString().trim()
            : 'Yuz tekshiruvi muvaffaqiyatsiz.',
      );
    }
    debugPrint(
      '[FACE_VERIFY] response success '
      'request_id=${map['request_id']} message=${map['message']}',
    );
    return const _FaceVerifyResult(isSuccess: true);
  } on DioException catch (e) {
    final payload = e.response?.data;
    debugPrint(
      '[FACE_VERIFY] DioException status=${e.response?.statusCode} '
      'message=${e.message} payload=${_preview(payload)}',
    );
    String? message;
    if (payload is Map) {
      final raw = payload['message'] ?? payload['detail'];
      message = raw?.toString();
    }
    return _FaceVerifyResult(
      isSuccess: false,
      message: (message?.trim().isNotEmpty ?? false)
          ? message!.trim()
          : (e.message ?? 'Face verification so‘rovi amalga oshmadi.'),
    );
  } catch (_) {
    return const _FaceVerifyResult(
      isSuccess: false,
      message: 'Yuz rasmini yuborishda xatolik yuz berdi.',
    );
  }
}

bool? _parseBool(dynamic value) {
  if (value is bool) return value;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

String _preview(Object? value, {int max = 180}) {
  if (value == null) return '';
  final text = value.toString().replaceAll('\n', ' ');
  if (text.length <= max) return text;
  return '${text.substring(0, max)}...';
}

String _normalizeBase64(String input) {
  final value = input.trim();
  final commaIndex = value.indexOf(',');
  if (commaIndex > -1) {
    return value.substring(commaIndex + 1).trim();
  }
  return value;
}

Future<String> _getOrCreateDeviceId() async {
  const key = 'face_verification_device_id';
  final prefs = getIt<SharedPreferences>();
  final saved = prefs.getString(key);
  if (saved != null && saved.isNotEmpty) return saved;

  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  final generated = base64UrlEncode(bytes).replaceAll('=', '');
  await prefs.setString(key, generated);
  return generated;
}

class _FaceVerifyResult {
  const _FaceVerifyResult({required this.isSuccess, this.message});

  final bool isSuccess;
  final String? message;
}
