abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;
}

// Server xatoliklari uchun
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});

  factory ServerFailure.fromStatusCode(
    int statusCode, {
    String? customMessage,
  }) {
    switch (statusCode) {
      case 400:
        return ServerFailure(
          customMessage ?? "Noto'g'ri so'rov",
          statusCode: statusCode,
        );
      case 401:
        return ServerFailure(
          customMessage ?? "Avtorizatsiya xatoligi",
          statusCode: statusCode,
        );
      case 403:
        return ServerFailure(
          customMessage ?? "Ruxsat berilmagan",
          statusCode: statusCode,
        );
      case 404:
        return ServerFailure(
          customMessage ?? "Ma'lumot topilmadi",
          statusCode: statusCode,
        );
      case 422:
        return ServerFailure(
          customMessage ?? "Ma'lumotlar noto'g'ri",
          statusCode: statusCode,
        );
      case 500:
        return ServerFailure(
          customMessage ?? "Server ichki xatoligi",
          statusCode: statusCode,
        );
      case 502:
        return ServerFailure(
          customMessage ?? "Bad Gateway",
          statusCode: statusCode,
        );
      case 503:
        return ServerFailure(
          customMessage ?? "Xizmat vaqtincha mavjud emas",
          statusCode: statusCode,
        );
      default:
        return ServerFailure(
          customMessage ?? "Server xatoligi ($statusCode)",
          statusCode: statusCode,
        );
    }
  }
}

// Tarmoq xatoliklari uchun
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});

  factory NetworkFailure.noConnection() {
    return const NetworkFailure("Internet aloqasi yo'q");
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure("So'rov vaqti tugadi");
  }

  factory NetworkFailure.connectionError() {
    return const NetworkFailure("Serverga ulanib bo'lmadi");
  }

  factory NetworkFailure.unknown(String error) {
    return NetworkFailure("Tarmoq xatoligi: $error");
  }
}

// Validatsiya xatoliklari uchun
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode});

  factory ValidationFailure.invalidPhone() {
    return const ValidationFailure("Telefon raqam noto'g'ri formatda");
  }

  factory ValidationFailure.invalidPassword() {
    return const ValidationFailure("Parol noto'g'ri formatda");
  }

  factory ValidationFailure.emptyField(String fieldName) {
    return ValidationFailure("$fieldName maydoni bo'sh bo'lishi mumkin emas");
  }

  factory ValidationFailure.invalidEmail() {
    return const ValidationFailure("Email noto'g'ri formatda");
  }

  factory ValidationFailure.custom(String message) {
    return ValidationFailure(message);
  }
}

// Kesh xatoliklari uchun
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.statusCode});

  factory CacheFailure.notFound() {
    return const CacheFailure("Ma'lumot keshda topilmadi");
  }

  factory CacheFailure.writeError() {
    return const CacheFailure("Keshga yozishda xatolik");
  }

  factory CacheFailure.readError() {
    return const CacheFailure("Keshdan o'qishda xatolik");
  }
}

// Autentifikatsiya xatoliklari uchun
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure("Login yoki parol noto'g'ri");
  }

  factory AuthFailure.tokenExpired() {
    return const AuthFailure("Token muddati tugagan");
  }

  factory AuthFailure.unauthorized() {
    return const AuthFailure("Ruxsat berilmagan");
  }

  factory AuthFailure.userNotFound() {
    return const AuthFailure("Foydalanuvchi topilmadi");
  }

  factory AuthFailure.accountBlocked() {
    return const AuthFailure("Hisob bloklangan");
  }
}

// Permission xatoliklari uchun
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.statusCode});

  factory PermissionFailure.denied() {
    return const PermissionFailure("Ruxsat berilmadi");
  }

  factory PermissionFailure.permanentlyDenied() {
    return const PermissionFailure("Ruxsat butunlay bekor qilindi");
  }

  factory PermissionFailure.restricted() {
    return const PermissionFailure("Ruxsat cheklangan");
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
