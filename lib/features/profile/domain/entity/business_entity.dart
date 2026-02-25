import 'package:equatable/equatable.dart';

class BusinessEntity extends Equatable {
  final String? id;
  final String name;
  final String? avatarPath;
  final String? bannerPath;
  final String workDays;
  final String workHours;
  final List<String> contacts;
  final String instagram;
  final String facebook;
  final String telegram;
  final String youtube;
  final String bio;
  final String addressCity;
  final String addressRoad;
  final String addressHome;
  final String addressOrientation;
  final double? addressLat;
  final double? addressLong;

  const BusinessEntity({
    this.id,
    required this.name,
    this.avatarPath,
    this.bannerPath,
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
    this.addressLat,
    this.addressLong,
  });

  Map<String, dynamic> toMap() {
    String? validUrlOrNull(String url) {
      if (url.isEmpty) return null;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'https://$url';
      }
      return url;
    }

    final map = <String, dynamic>{
      'name': name,
      'work_days': workDays,
      'work_hours': workHours,
      'bio': bio,
      'address_city': addressCity,
      'address_road': addressRoad,
      'address_home': addressHome,
      'address_orientation': addressOrientation,
      'address_lat': addressLat ?? 41.2995,
      'address_long': addressLong ?? 69.2401,
    };

    final inst = validUrlOrNull(instagram);
    if (inst != null) map['instagram'] = inst;

    final fb = validUrlOrNull(facebook);
    if (fb != null) map['facebook'] = fb;

    final tg = validUrlOrNull(telegram);
    if (tg != null) map['telegram'] = tg;

    final yt = validUrlOrNull(youtube);
    if (yt != null) map['youtube'] = yt;

    if (contacts.isNotEmpty) {
      final contactsMap = <Map<String, dynamic>>[];
      for (int i = 0; i < contacts.length; i++) {
        contactsMap.add({'phone': contacts[i]});
      }
      map['contacts'] = contactsMap;
    }

    return map;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarPath,
    bannerPath,
    workDays,
    workHours,
    contacts,
    instagram,
    facebook,
    telegram,
    youtube,
    bio,
    addressCity,
    addressRoad,
    addressHome,
    addressOrientation,
    addressLat,
    addressLong,
  ];
}
