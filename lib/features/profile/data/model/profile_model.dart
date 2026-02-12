
import 'dart:convert';

class ProfileModel {
    final bool status;
    final Data data;

    ProfileModel({
        required this.status,
        required this.data,
    });

    factory ProfileModel.fromJson(String str) => ProfileModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ProfileModel.fromMap(Map<String, dynamic> json) => ProfileModel(
        status: json["status"],
        data: Data.fromMap(json["data"]),
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "data": data.toMap(),
    };
}

class Data {
    final String detail;
    final Token token;
    final bool askName;
    final User user;

    Data({
        required this.detail,
        required this.token,
        required this.askName,
        required this.user,
    });

    factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Data.fromMap(Map<String, dynamic> json) => Data(
        detail: json["detail"],
        token: Token.fromMap(json["token"]),
        askName: json["ask_name"],
        user: User.fromMap(json["user"]),
    );

    Map<String, dynamic> toMap() => {
        "detail": detail,
        "token": token.toMap(),
        "ask_name": askName,
        "user": user.toMap(),
    };
}

class Token {
    final String access;
    final String refresh;

    Token({
        required this.access,
        required this.refresh,
    });

    factory Token.fromJson(String str) => Token.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Token.fromMap(Map<String, dynamic> json) => Token(
        access: json["access"],
        refresh: json["refresh"],
    );

    Map<String, dynamic> toMap() => {
        "access": access,
        "refresh": refresh,
    };
}

class User {
    final int id;
    final DateTime lastLogin;
    final bool isSuperuser;
    final String firstName;
    final String lastName;
    final String email;
    final bool isStaff;
    final bool isActive;
    final DateTime dateJoined;
    final String phone;
    final String username;
    final DateTime validatedAt;
    final bool isVerify;
    final String accountType;
    final String role;
    final String avatar;

    User({
        required this.id,
        required this.lastLogin,
        required this.isSuperuser,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.isStaff,
        required this.isActive,
        required this.dateJoined,
        required this.phone,
        required this.username,
        required this.validatedAt,
        required this.isVerify,
        required this.accountType,
        required this.role,
        required this.avatar,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        lastLogin: DateTime.parse(json["last_login"]),
        isSuperuser: json["is_superuser"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        isStaff: json["is_staff"],
        isActive: json["is_active"],
        dateJoined: DateTime.parse(json["date_joined"]),
        phone: json["phone"],
        username: json["username"],
        validatedAt: DateTime.parse(json["validated_at"]),
        isVerify: json["is_verify"],
        accountType: json["account_type"],
        role: json["role"],
        avatar: json["avatar"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "last_login": lastLogin.toIso8601String(),
        "is_superuser": isSuperuser,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "is_staff": isStaff,
        "is_active": isActive,
        "date_joined": dateJoined.toIso8601String(),
        "phone": phone,
        "username": username,
        "validated_at": validatedAt.toIso8601String(),
        "is_verify": isVerify,
        "account_type": accountType,
        "role": role,
        "avatar": avatar,
    };
}
