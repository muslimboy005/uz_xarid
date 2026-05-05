/// YuzID / SoliqID integratsiyasi.
/// Maxfiy ma'lumotlar uchun release buildda `--dart-define=YUZID_LOGIN=...` va
/// `--dart-define=YUZID_PASSWORD=...` ishlatish tavsiya etiladi.
abstract final class YuzIdConfig {
  static const String apiBase = 'https://api.yuzid.uz';

  static const String basicAuthLogin = String.fromEnvironment(
    'YUZID_LOGIN',
    defaultValue: 'uzxarid',
  );

  static const String basicAuthPassword = String.fromEnvironment(
    'YUZID_PASSWORD',
    defaultValue: 'an2t-E8j',
  );

  /// Bo‘sh bo‘lsa, SoliqId ga `applicationGuid` uzatilmaydi (plugin ixtiyoriy).
  static String? get applicationGuid {
    const v = String.fromEnvironment('YUZID_APP_GUID');
    return v.isEmpty ? null : v;
  }
}
