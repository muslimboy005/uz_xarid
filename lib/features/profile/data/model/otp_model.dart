class OtpModel {
  final String phone;
  final String otp;
  final String message;

  OtpModel({
    required this.message,
    required this.otp,
    required this.phone,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      message: json['message'] ?? '',
      otp: json['otp'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'OtpModel(phone: $phone, otp: $otp, message: $message)';
  }
}
