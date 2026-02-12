import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? mobileImage;
  final String? desktopImage;
  final String? link;
  final String? textColor;
  final String? backgroundColor;

  const BannerEntity({
    required this.id,
    required this.title,
    this.description,
    this.mobileImage,
    this.desktopImage,
    this.link,
    this.textColor,
    this.backgroundColor,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    mobileImage,
    desktopImage,
    link,
    textColor,
    backgroundColor,
  ];
}
