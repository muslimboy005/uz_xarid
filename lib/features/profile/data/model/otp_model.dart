
class OtpModel {
  final String phone;
  final String? otp;

  OtpModel({
    required this.phone,
    this.otp,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      phone: json['phone'] ?? '',
      otp: json['otp'] ?? json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      if (otp != null) 'code': otp, // Backend 'code' kutadi
    };
  }

  @override
  String toString() {
    return 'OtpModel(phone: $phone, otp: ${otp != null ? '******' : 'null'})';
  }
}