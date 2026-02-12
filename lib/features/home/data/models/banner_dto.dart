import 'package:uz_xarid/features/home/domain/entities/banner_entity.dart';

class BannerDto {
  final int id;
  final String title;
  final String? description;
  final String? mobileImage;
  final String? desktopImage;
  final String? link;
  final String? textColor;
  final String? backgroundColor;

  BannerDto({
    required this.id,
    required this.title,
    this.description,
    this.mobileImage,
    this.desktopImage,
    this.link,
    this.textColor,
    this.backgroundColor,
  });

  factory BannerDto.fromJson(Map<String, dynamic> json) {
    return BannerDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      mobileImage: json['mobile_image'] as String?,
      desktopImage: json['desktop_image'] as String?,
      link: json['link'] as String?,
      textColor: json['text_color'] as String?,
      backgroundColor: json['background_color'] as String?,
    );
  }

  BannerDto copyWith({
    int? id,
    String? title,
    String? description,
    String? mobileImage,
    String? desktopImage,
    String? link,
    String? textColor,
    String? backgroundColor,
  }) {
    return BannerDto(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mobileImage: mobileImage ?? this.mobileImage,
      desktopImage: desktopImage ?? this.desktopImage,
      link: link ?? this.link,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  BannerEntity toEntity() => BannerEntity(
    id: id,
    title: title,
    description: description,
    mobileImage: mobileImage,
    desktopImage: desktopImage,
    link: link,
    textColor: textColor,
    backgroundColor: backgroundColor,
  );
}

class BannerResponseDto {
  final bool status;
  final BannerResponseData data;

  BannerResponseDto({required this.status, required this.data});

  factory BannerResponseDto.fromJson(Map<String, dynamic> json) {
    return BannerResponseDto(
      status: json['status'] as bool? ?? false,
      data: BannerResponseData.fromJson(
        json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class BannerResponseData {
  final List<BannerDto> results;

  const BannerResponseData({required this.results});

  factory BannerResponseData.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>? ?? const []).map((e) {
      return BannerDto.fromJson(e as Map<String, dynamic>);
    }).toList();

    return BannerResponseData(results: list);
  }
}
