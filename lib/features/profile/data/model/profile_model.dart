
class ProfileModel {
  final bool status;
  final ProfileData data;

  ProfileModel({required this.status, required this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {

    return ProfileModel(
      status: json['status'] ?? false,
      data: json['data'] is Map<String, dynamic>
          ? ProfileData.fromJson(json['data'])
          : ProfileData.fromJson({}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class ProfileData {
  final String? detail;
  final Token? token;
  final bool askName;
  final User? user;

  ProfileData({this.detail, this.token, this.askName = false, this.user});

  factory ProfileData.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return ProfileData();
    }


    User? user;
    if (json['user'] != null) {
      user = User.fromJson(json['user']);
    } else if (json['id'] != null) {
      user = User.fromJson(json);
    }

    return ProfileData(
      detail: json['detail'],
      token: json['token'] != null ? Token.fromJson(json['token']) : null,
      askName: json['ask_name'] ?? json['askName'] ?? false,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (detail != null) 'detail': detail,
      if (token != null) 'token': token!.toJson(),
      'ask_name': askName,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class Token {
  final String access;
  final String refresh;

  Token({required this.access, required this.refresh});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(access: json['access'] ?? '', refresh: json['refresh'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'access': access, 'refresh': refresh};
  }
}

class User {
  final int? id;
  final DateTime? lastLogin;
  final bool isSuperuser;
  final String firstName;
  final String lastName;
  final String email;
  final bool isStaff;
  final bool isActive;
  final DateTime? dateJoined;
  final String phone;
  final String username;
  final DateTime? validatedAt;
  final bool isVerify;
  final String accountType;
  final String role;
  final String avatar;

  User({
    this.id,
    this.lastLogin,
    this.isSuperuser = false,
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.isStaff = false,
    this.isActive = true,
    this.dateJoined,
    required this.phone,
    this.username = '',
    this.validatedAt,
    this.isVerify = false,
    this.accountType = 'basic',
    this.role = 'user',
    this.avatar = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
      id: json['id'],
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      isSuperuser: json['is_superuser'] ?? false,
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      isStaff: json['is_staff'] ?? false,
      isActive: json['is_active'] ?? true,
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'])
          : null,
      phone: json['phone'] ?? '',
      username: json['username'] ?? '',
      validatedAt: json['validated_at'] != null
          ? DateTime.tryParse(json['validated_at'])
          : null,
      isVerify: json['is_verify'] ?? false,
      accountType: json['account_type'] ?? 'basic',
      role: json['role'] ?? 'user',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      'is_superuser': isSuperuser,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'is_staff': isStaff,
      'is_active': isActive,
      if (dateJoined != null) 'date_joined': dateJoined!.toIso8601String(),
      'phone': phone,
      'username': username,
      if (validatedAt != null) 'validated_at': validatedAt!.toIso8601String(),
      'is_verify': isVerify,
      'account_type': accountType,
      'role': role,
      'avatar': avatar,
    };
  }
}
