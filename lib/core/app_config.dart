import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// The package name to use for loading assets.
  /// Should be null when running as a standalone app,
  /// and 'uzxarid' when running as a package dependency.
  static String? packageName;

  /// Shared secret used to sign outbound API requests (HMAC-SHA256 over iv+ts).
  /// Loaded from the `.env` file at app start via [dotenv.load].
  static String get masterSecret => dotenv.env['PAYLOAD_MASTER_SECRET'] ?? '';
}
