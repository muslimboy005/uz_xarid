class FullNameEntity {
  final String firstName;
  final String lastName;

  FullNameEntity({required this.firstName, required this.lastName});
}

class ProfileUpdateEntity {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? gender;
  final String? birthDate;
  final String? city;
  final String? street;
  final String? house;
  final String? district;
  final String? avatarPath;

  ProfileUpdateEntity({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.gender,
    this.birthDate,
    this.city,
    this.street,
    this.house,
    this.district,
    this.avatarPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (birthDate != null && birthDate!.isNotEmpty) 'birth_date': birthDate,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (street != null && street!.isNotEmpty) 'street': street,
      if (house != null && house!.isNotEmpty) 'house': house,
      if (district != null && district!.isNotEmpty) 'district': district,
    };
  }
}
