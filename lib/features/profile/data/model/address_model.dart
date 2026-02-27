class AddressResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<AddressModel> results;

  AddressResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory AddressResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final links = data['links'] ?? {};

    return AddressResponseModel(
      count: data['total_items'] ?? data['count'] ?? 0,
      next: links['next'] ?? data['next'],
      previous: links['previous'] ?? data['previous'],
      results: data['results'] != null
          ? List<AddressModel>.from(
              data['results'].map((x) => AddressModel.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((x) => x.toJson()).toList(),
    };
  }
}

class AddressModel {
  final int? id;
  final String name;
  final String address;
  final String apartment;
  final String entrance;
  final String floor;
  final String comment;
  final double longitude;
  final double latitude;

  AddressModel({
    this.id,
    required this.name,
    required this.address,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.comment,
    required this.longitude,
    required this.latitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      apartment: json['apartment'] ?? '',
      entrance: json['entrance'] ?? '',
      floor: json['floor'] ?? '',
      comment: json['comment'] ?? '',
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'apartment': apartment,
      'entrance': entrance,
      'floor': floor,
      'comment': comment,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
