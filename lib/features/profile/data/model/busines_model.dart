import 'dart:convert';

class BusinesModel {
    final String name;
    final String avatar;
    final String banner;
    final String workDays;
    final String workHours;
    final List<Contact> contacts;
    final String instagram;
    final String facebook;
    final String telegram;
    final String youtube;
    final String bio;
    final String addressCity;
    final String addressRoad;
    final String addressHome;
    final String addressOrientation;
    final int addressLat;
    final int addressLong;

    BusinesModel({
        required this.name,
        required this.avatar,
        required this.banner,
        required this.workDays,
        required this.workHours,
        required this.contacts,
        required this.instagram,
        required this.facebook,
        required this.telegram,
        required this.youtube,
        required this.bio,
        required this.addressCity,
        required this.addressRoad,
        required this.addressHome,
        required this.addressOrientation,
        required this.addressLat,
        required this.addressLong,
    });

    factory BusinesModel.fromJson(String str) => BusinesModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory BusinesModel.fromMap(Map<String, dynamic> json) => BusinesModel(
        name: json["name"],
        avatar: json["avatar"],
        banner: json["banner"],
        workDays: json["work_days"],
        workHours: json["work_hours"],
        contacts: List<Contact>.from(json["contacts"].map((x) => Contact.fromMap(x))),
        instagram: json["instagram"],
        facebook: json["facebook"],
        telegram: json["telegram"],
        youtube: json["youtube"],
        bio: json["bio"],
        addressCity: json["address_city"],
        addressRoad: json["address_road"],
        addressHome: json["address_home"],
        addressOrientation: json["address_orientation"],
        addressLat: json["address_lat"],
        addressLong: json["address_long"],
    );

    Map<String, dynamic> toMap() => {
        "name": name,
        "avatar": avatar,
        "banner": banner,
        "work_days": workDays,
        "work_hours": workHours,
        "contacts": List<dynamic>.from(contacts.map((x) => x.toMap())),
        "instagram": instagram,
        "facebook": facebook,
        "telegram": telegram,
        "youtube": youtube,
        "bio": bio,
        "address_city": addressCity,
        "address_road": addressRoad,
        "address_home": addressHome,
        "address_orientation": addressOrientation,
        "address_lat": addressLat,
        "address_long": addressLong,
    };
}

class Contact {
    final String additionalProp1;
    final String additionalProp2;
    final String additionalProp3;

    Contact({
        required this.additionalProp1,
        required this.additionalProp2,
        required this.additionalProp3,
    });

    factory Contact.fromJson(String str) => Contact.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Contact.fromMap(Map<String, dynamic> json) => Contact(
        additionalProp1: json["additionalProp1"],
        additionalProp2: json["additionalProp2"],
        additionalProp3: json["additionalProp3"],
    );

    Map<String, dynamic> toMap() => {
        "additionalProp1": additionalProp1,
        "additionalProp2": additionalProp2,
        "additionalProp3": additionalProp3,
    };
}
