/// Viloyat / tuman / mahalla — API dan keladigan joy nomi va koordinata.
class LocationPlaceEntity {
  const LocationPlaceEntity({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final double? latitude;
  final double? longitude;
}
