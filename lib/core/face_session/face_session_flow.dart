// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soliq_id/localizations_util.dart';
import 'package:soliq_id/soliq_id.dart';
import 'package:uzxarid/core/config/yuzid_config.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/soliq_id/soliq_id_flow.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';

/// Public result returned by the orchestrated Face ID flow.
class FaceSessionResult {
  const FaceSessionResult({required this.isSuccess, this.message});

  final bool isSuccess;
  final String? message;
}

enum FaceSessionRole { individual, ytt, selfEmployed, legal }

extension FaceSessionRoleX on FaceSessionRole {
  String get apiType => switch (this) {
    FaceSessionRole.individual => 'individual',
    FaceSessionRole.ytt => 'ytt',
    FaceSessionRole.selfEmployed => 'self_employed',
    FaceSessionRole.legal => 'legal',
  };

  String get title => switch (this) {
    FaceSessionRole.individual => 'Jismoniy shaxs',
    FaceSessionRole.ytt => 'Yakka tartibdagi tadbirkor',
    FaceSessionRole.selfEmployed => 'O‘zini o‘zi band qilgan',
    FaceSessionRole.legal => 'Yuridik shaxs',
  };

  String get subtitle => switch (this) {
    FaceSessionRole.individual =>
      'Passport orqali shaxsiy tasdiqlash. Soliq STIR talab qilinmaydi.',
    FaceSessionRole.ytt =>
      'YTT STIR (JSHSHIR) raqami orqali tadbirkor sifatida tasdiqlash.',
    FaceSessionRole.selfEmployed =>
      'O‘zini o‘zi band qilgan shaxs sifatida tasdiqlash.',
    FaceSessionRole.legal =>
      'Tashkilot STIR raqami orqali yuridik shaxs sifatida tasdiqlash.',
  };

  IconData get icon => switch (this) {
    FaceSessionRole.individual => Icons.person_outline_rounded,
    FaceSessionRole.ytt => Icons.work_outline_rounded,
    FaceSessionRole.selfEmployed => Icons.badge_outlined,
    FaceSessionRole.legal => Icons.apartment_outlined,
  };

  bool get requiresDocument => this != FaceSessionRole.individual;

  /// YTT / self-employed: pinfl 14 ta raqam. Legal: STIR 9 ta raqam.
  int get documentMaxLength =>
      this == FaceSessionRole.legal ? 9 : 14;

  String get documentLabel => this == FaceSessionRole.legal
      ? 'Tashkilot STIR (9 ta raqam)'
      : 'JSHSHIR (14 ta raqam)';
}

class _StartResult {
  const _StartResult({
    required this.verificationId,
    required this.didox,
  });

  final String verificationId;
  final Map<String, dynamic>? didox;
}

/// Public entry. Drives the entire role → start → confirm → success flow.
Future<FaceSessionResult> runFaceSessionVerification(
  BuildContext context, {
  LocalizationType localization = LocalizationType.UZ,
}) async {
  while (true) {
    if (!context.mounted) {
      return const FaceSessionResult(isSuccess: false);
    }
    final role = await Navigator.of(context).push<FaceSessionRole>(
      MaterialPageRoute(builder: (_) => const _RoleSelectionScreen()),
    );
    if (role == null) {
      return const FaceSessionResult(isSuccess: false);
    }

    final outcome = await _runForRole(
      context,
      role: role,
      localization: localization,
    );
    if (outcome != null) return outcome;
    // outcome == null => kullanıcı "rollarga qaytish" tanladi: aylanaga davom etamiz.
  }
}

Future<FaceSessionResult?> _runForRole(
  BuildContext context, {
  required FaceSessionRole role,
  required LocalizationType localization,
}) async {
  String? document;
  if (role.requiresDocument) {
    document = await _showDocumentBottomSheet(context, role: role);
    if (document == null || document.isEmpty) {
      return null;
    }
  }

  if (!context.mounted) return const FaceSessionResult(isSuccess: false);

  final start = await _showLoaderWhile<_StartOutcome>(
    context,
    () => _callSessionStart(role: role, document: document),
  );
  if (!context.mounted) return const FaceSessionResult(isSuccess: false);

  if (start.error != null) {
    final backToRoles = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _FaceErrorScreen(
          title: 'Tasdiqlash imkonsiz',
          message: start.error!,
          ctaLabel: 'Rolni qayta tanlash',
        ),
      ),
    );
    if (backToRoles == true) return null; // role selectorga qaytaramiz.
    return FaceSessionResult(isSuccess: false, message: start.error);
  }

  final didox = start.result!.didox;
  // Role bo‘yicha didox tekshiruvi.
  if (role == FaceSessionRole.selfEmployed) {
    final isSelfEmployed = _asBool(didox?['is_self_employed']) ?? false;
    if (!isSelfEmployed) {
      if (!context.mounted) return const FaceSessionResult(isSuccess: false);
      final backToRoles = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const _FaceErrorScreen(
            title: 'Siz o‘zini o‘zi band qilmagansiz',
            message:
                'Tizim ma\'lumotlariga ko‘ra siz o‘zini o‘zi band qilgan shaxs sifatida ro‘yxatdan o‘tmagansiz. Iltimos, boshqa rol tanlang yoki maqomingizni tasdiqlang.',
            ctaLabel: 'Rolni qayta tanlash',
          ),
        ),
      );
      if (backToRoles == true) return null;
      return const FaceSessionResult(
        isSuccess: false,
        message: 'Siz o‘zini o‘zi band qilmagansiz.',
      );
    }
  } else if (role == FaceSessionRole.ytt) {
    final isIdt = _asBool(didox?['isIdt']) ?? false;
    if (!isIdt) {
      if (!context.mounted) return const FaceSessionResult(isSuccess: false);
      final backToRoles = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const _FaceErrorScreen(
            title: 'Bu JSHSHIR YTT emas',
            message:
                'Kiritilgan JSHSHIR yakka tartibdagi tadbirkorga tegishli emas. Iltimos, boshqa raqam yoki rolni tanlang.',
            ctaLabel: 'Rolni qayta tanlash',
          ),
        ),
      );
      if (backToRoles == true) return null;
      return const FaceSessionResult(
        isSuccess: false,
        message: 'JSHSHIR YTT sifatida topilmadi.',
      );
    }
  }

  // didox tasdiqlash ekrani (individual'dan tashqari).
  if (role.requiresDocument && didox != null) {
    if (!context.mounted) return const FaceSessionResult(isSuccess: false);
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _DidoxConfirmScreen(role: role, didox: didox),
      ),
    );
    if (confirmed != true) return null;
  }

  // Passport ma'lumotlari + face scan.
  if (!context.mounted) return const FaceSessionResult(isSuccess: false);
  final identity = await showSoliqIdentityInputSheet(context);
  if (identity == null) {
    return null;
  }

  if (!context.mounted) return const FaceSessionResult(isSuccess: false);
  final scan = await _runFaceCapture(
    context,
    identity: identity,
    localization: localization,
  );
  if (!scan.isSuccess || scan.imageBytes == null) {
    return FaceSessionResult(
      isSuccess: false,
      message: scan.failureMessage ?? 'Face ID natijasi olinmadi.',
    );
  }

  // Confirm so‘rovi.
  if (!context.mounted) return const FaceSessionResult(isSuccess: false);
  final confirm = await _showLoaderWhile<_ConfirmOutcome>(
    context,
    () => _callSessionConfirm(
      verificationId: start.result!.verificationId,
      identity: identity,
      faceData: scan.faceData ?? const {},
      imageBytes: scan.imageBytes!,
    ),
  );
  if (!context.mounted) return const FaceSessionResult(isSuccess: false);

  if (!confirm.verified) {
    final backToRoles = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _FaceErrorScreen(
          title: 'Yuz tekshiruvi muvaffaqiyatsiz',
          message:
              confirm.message ?? 'Tasdiqlash bajarilmadi. Qayta urinib ko‘ring.',
          ctaLabel: 'Rolni qayta tanlash',
        ),
      ),
    );
    if (backToRoles == true) return null;
    return FaceSessionResult(isSuccess: false, message: confirm.message);
  }

  // Muvaffaqiyatli — alohida success screen.
  if (!context.mounted) return const FaceSessionResult(isSuccess: true);
  await Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const FaceVerificationSuccessScreen()),
  );
  return const FaceSessionResult(isSuccess: true);
}

class _StartOutcome {
  const _StartOutcome({this.result, this.error});

  final _StartResult? result;
  final String? error;
}

class _ConfirmOutcome {
  const _ConfirmOutcome({required this.verified, this.message});

  final bool verified;
  final String? message;
}

class _FaceCaptureOutcome {
  const _FaceCaptureOutcome({
    required this.isSuccess,
    this.failureMessage,
    this.imageBytes,
    this.faceData,
  });

  final bool isSuccess;
  final String? failureMessage;
  final List<int>? imageBytes;
  final Map<String, dynamic>? faceData;
}

Future<_StartOutcome> _callSessionStart({
  required FaceSessionRole role,
  String? document,
}) async {
  try {
    final dio = getIt<DioClient>().dio;
    final body = <String, dynamic>{'type': role.apiType};
    if (document != null && document.isNotEmpty) {
      body['document'] = document;
    }
    final response = await dio.post(
      'face/session/start/',
      data: body,
      options: Options(contentType: 'application/json'),
    );
    final data = response.data;
    if (data is! Map) {
      return const _StartOutcome(error: 'Server javobi noto‘g‘ri formatda.');
    }
    final map = Map<String, dynamic>.from(data);
    final id = map['verification_id']?.toString();
    if (id == null || id.isEmpty) {
      return const _StartOutcome(error: 'verification_id qaytmadi.');
    }
    Map<String, dynamic>? didox;
    final raw = map['didox'];
    if (raw is Map) {
      didox = Map<String, dynamic>.from(raw);
    }
    return _StartOutcome(
      result: _StartResult(verificationId: id, didox: didox),
    );
  } on DioException catch (e) {
    final payload = e.response?.data;
    String? message;
    if (payload is Map) {
      message = (payload['detail'] ?? payload['message'])?.toString();
    }
    return _StartOutcome(
      error: (message?.trim().isNotEmpty ?? false)
          ? message!.trim()
          : (e.message ?? 'So‘rov amalga oshmadi.'),
    );
  } catch (_) {
    return const _StartOutcome(error: 'Kutilmagan xatolik yuz berdi.');
  }
}

Future<_ConfirmOutcome> _callSessionConfirm({
  required String verificationId,
  required SoliqIdentityInput identity,
  required Map<String, dynamic> faceData,
  required List<int> imageBytes,
}) async {
  try {
    final dio = getIt<DioClient>().dio;
    final pinfl = faceData['pinfl']?.toString() ?? '';
    final name = faceData['name']?.toString() ?? '';
    final surName = faceData['surName']?.toString() ?? '';
    final patronymicName = faceData['patronymicName']?.toString() ?? '';
    final birthDateRaw = faceData['birthDate']?.toString() ?? identity.birthDate;
    final dateOfBirth = _normalizeBirthDateForApi(birthDateRaw);
    final confidence = faceData['confidence']?.toString() ?? '0.98';
    final formData = FormData.fromMap({
      'verification_id': verificationId,
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
      'status': 'success',
      'pinfl': pinfl,
      'confidence': confidence,
      'name': name,
      'surName': surName,
      'patronymicName': patronymicName,
      'date_of_birth': dateOfBirth,
      'passport_series': identity.passportSeries,
      'passport_number': identity.passportNumber,
    });
    final response = await dio.post(
      'face/session/confirm/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = response.data;
    if (data is! Map) {
      return const _ConfirmOutcome(
        verified: false,
        message: 'Confirm javobi noto‘g‘ri formatda.',
      );
    }
    final map = Map<String, dynamic>.from(data);
    final verified = _asBool(map['verified']) == true;
    final faceVerified = _asBool(map['is_face_verified']) == true;
    if (verified && faceVerified) {
      return const _ConfirmOutcome(verified: true);
    }
    return _ConfirmOutcome(
      verified: false,
      message: (map['message']?.toString().trim().isNotEmpty ?? false)
          ? map['message'].toString().trim()
          : 'Yuz tekshiruvi muvaffaqiyatsiz.',
    );
  } on DioException catch (e) {
    final payload = e.response?.data;
    String? message;
    if (payload is Map) {
      message = (payload['detail'] ?? payload['message'])?.toString();
    }
    return _ConfirmOutcome(
      verified: false,
      message: (message?.trim().isNotEmpty ?? false)
          ? message!.trim()
          : (e.message ?? 'Confirm so‘rovi amalga oshmadi.'),
    );
  } catch (_) {
    return const _ConfirmOutcome(
      verified: false,
      message: 'Yuz rasmini yuborishda xatolik yuz berdi.',
    );
  }
}

/// SoliqId vidjetini ishga tushiradi va `image` + `data` ni qaytaradi.
Future<_FaceCaptureOutcome> _runFaceCapture(
  BuildContext context, {
  required SoliqIdentityInput identity,
  required LocalizationType localization,
}) async {
  Map<String, dynamic>? scanResult;
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
            final parsed = _parseDynamicPayload(event);
            if (parsed != null) scanResult = parsed;
          },
        ),
      ),
    );
  } catch (e) {
    return _FaceCaptureOutcome(
      isSuccess: false,
      failureMessage: e.toString(),
    );
  }

  scanResult ??= _parseDynamicPayload(routeResult);

  if (scanResult == null) {
    return const _FaceCaptureOutcome(
      isSuccess: false,
      failureMessage: 'Face ID natijasi olinmadi.',
    );
  }

  final faceData = _extractFaceData(scanResult);
  final imageBase64 = _extractFaceImage(scanResult);
  if (imageBase64 != null && imageBase64.isNotEmpty) {
    final bytes = _decodeBase64Image(imageBase64);
    if (bytes != null) {
      return _FaceCaptureOutcome(
        isSuccess: true,
        imageBytes: bytes,
        faceData: faceData,
      );
    }
  }

  final msg = scanResult?['message']?.toString();
  return _FaceCaptureOutcome(
    isSuccess: false,
    failureMessage: (msg != null && msg.trim().isNotEmpty)
        ? msg.trim()
        : 'Yuz rasmi olinmadi.',
  );
}

// ─── Bottomsheet / Screens ──────────────────────────────────────

class _RoleSelectionScreen extends StatelessWidget {
  const _RoleSelectionScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final roles = FaceSessionRole.values;
    return Scaffold(
      backgroundColor: context.bodyBackground,
      appBar: AppBar(
        backgroundColor: context.bodyBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Yuz ID tasdiqlash',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primaryColor.withValues(alpha: 0.16),
                          context.primaryColor.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.face_retouching_natural,
                      color: context.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Toifangizni tanlang',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Yuz ID jarayonini boshlash uchun siz qaysi maqomda harakat qilayotganingizni tanlang.',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < roles.length; i++) ...[
                    _RoleCard(
                      role: roles[i],
                      onTap: () => Navigator.of(context).pop(roles[i]),
                      isDark: isDark,
                    ),
                    if (i < roles.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.onTap,
    required this.isDark,
  });

  final FaceSessionRole role;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    return Material(
      color: context.cardSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(role.icon, color: primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.subtitle,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: context.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _showDocumentBottomSheet(
  BuildContext context, {
  required FaceSessionRole role,
}) {
  final controller = TextEditingController();
  String? errorText;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.cardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  role.title,
                  style: TextStyle(
                    color: ctx.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sizni topishimiz uchun soliq raqamingizni kiriting.',
                  style: TextStyle(
                    color: ctx.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(role.documentMaxLength),
                  ],
                  style: TextStyle(color: ctx.textPrimary, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: role.documentLabel,
                    errorText: errorText,
                    filled: true,
                    fillColor: ctx.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: ctx.primaryColor, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctx.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final value = controller.text.trim();
                      if (value.length != role.documentMaxLength) {
                        setSheet(() {
                          errorText =
                              '${role.documentMaxLength} ta raqam bo‘lishi kerak';
                        });
                        return;
                      }
                      Navigator.of(ctx).pop(value);
                    },
                    child: const Text(
                      'Davom etish',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _DidoxConfirmScreen extends StatelessWidget {
  const _DidoxConfirmScreen({required this.role, required this.didox});

  final FaceSessionRole role;
  final Map<String, dynamic> didox;

  @override
  Widget build(BuildContext context) {
    final fullName = (didox['full_name'] ?? didox['name'] ?? didox['short_name'])
            ?.toString() ??
        '';
    final tin = didox['tin']?.toString() ?? '';
    final headline = switch (role) {
      FaceSessionRole.selfEmployed =>
        'Sizning o‘zini o‘zi band qilganingiz tasdiqlandi',
      FaceSessionRole.ytt => 'YTT ma\'lumotlari topildi',
      FaceSessionRole.legal => 'Tashkilot ma\'lumotlari topildi',
      FaceSessionRole.individual => 'Ma\'lumotlar topildi',
    };
    return Scaffold(
      backgroundColor: context.bodyBackground,
      appBar: AppBar(
        backgroundColor: context.bodyBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Tasdiqlash',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.green,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        headline,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Quyidagi ma\'lumotlar to‘g‘ri bo‘lsa, davom eting.',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _InfoTile(label: role.title, value: fullName),
                      if (tin.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _InfoTile(label: 'STIR', value: tin),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Davom etish',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceErrorScreen extends StatelessWidget {
  const _FaceErrorScreen({
    required this.title,
    required this.message,
    required this.ctaLabel,
  });

  final String title;
  final String message;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bodyBackground,
      appBar: AppBar(
        backgroundColor: context.bodyBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    ctaLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaceVerificationSuccessScreen extends StatelessWidget {
  const FaceVerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bodyBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.green.withValues(alpha: 0.22),
                            AppColors.green.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Yuz ID muvaffaqiyatli\ntasdiqlandi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Endi Uz Xarid platformasidan to‘liq foydalanishingiz mumkin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text(
                    'Davom etish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────

Future<T> _showLoaderWhile<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

Map<String, dynamic>? _parseDynamicPayload(dynamic payload) {
  if (payload == null) return null;
  if (payload is Map) return _toStringKeyMap(payload);
  if (payload is String) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return _toStringKeyMap(decoded);
    } catch (_) {}
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

Map<String, dynamic>? _extractFaceData(Map<String, dynamic>? payload) {
  if (payload == null) return null;
  final data = payload['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return _toStringKeyMap(data);
  return payload;
}

String? _extractFaceImage(dynamic payload) {
  if (payload == null) return null;
  if (payload is String) {
    final candidate = payload.trim();
    return _looksLikeBase64Image(candidate) ? candidate : null;
  }
  if (payload is List) {
    for (final item in payload) {
      final nested = _extractFaceImage(item);
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
      final nested = _extractFaceImage(payload[key]);
      if (nested != null) return nested;
    }
    for (final value in payload.values) {
      final nested = _extractFaceImage(value);
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

String _normalizeBase64(String input) {
  final value = input.trim();
  final commaIndex = value.indexOf(',');
  if (commaIndex > -1) {
    return value.substring(commaIndex + 1).trim();
  }
  return value;
}

List<int>? _decodeBase64Image(String value) {
  try {
    final normalized = _normalizeBase64(value).replaceAll(RegExp(r'\s'), '');
    return base64Decode(normalized);
  } catch (_) {
    return null;
  }
}

String _normalizeBirthDateForApi(String raw) {
  // SoliqId beradi: "01.05.1990" yoki "1990-05-01" — backend yyyy-MM-dd kutadi.
  final v = raw.trim();
  final dotted = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(v);
  if (dotted != null) {
    return '${dotted.group(3)}-${dotted.group(2)}-${dotted.group(1)}';
  }
  if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(v)) {
    return v.substring(0, 10);
  }
  return v;
}

