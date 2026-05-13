import 'package:json_annotation/json_annotation.dart';
import 'package:uzxarid/features/add_listing/domain/entities/location_place_entity.dart';

part 'location_place_dto.g.dart';

@JsonSerializable()
class LocationPlaceDto {
  const LocationPlaceDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region,
    this.district,
  });

  final int id;
  final String name;
  final String latitude;
  final String longitude;
  final int? region;
  final int? district;

  factory LocationPlaceDto.fromJson(Map<String, dynamic> json) =>
      _$LocationPlaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPlaceDtoToJson(this);

  LocationPlaceEntity toEntity() => LocationPlaceEntity(
        id: id,
        name: name,
        latitude: double.tryParse(latitude),
        longitude: double.tryParse(longitude),
      );
}

@JsonSerializable(explicitToJson: true)
class LocationPagedDataDto {
  const LocationPagedDataDto({
    required this.totalItems,
    required this.totalPages,
    required this.pageSize,
    required this.currentPage,
    required this.results,
  });

  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'page_size')
  final int pageSize;
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<LocationPlaceDto> results;

  factory LocationPagedDataDto.fromJson(Map<String, dynamic> json) =>
      _$LocationPagedDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPagedDataDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LocationPagedResponseDto {
  const LocationPagedResponseDto({
    required this.status,
    required this.data,
  });

  final bool status;
  final LocationPagedDataDto data;

  factory LocationPagedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LocationPagedResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPagedResponseDtoToJson(this);
}
