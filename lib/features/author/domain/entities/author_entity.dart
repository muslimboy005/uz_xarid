import 'package:equatable/equatable.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';

class AuthorEntity extends Equatable {
  const AuthorEntity({
    required this.id,
    required this.firstName,
    required this.lastName,

    this.phone,
    this.avatar,
    this.dateJoined,
    this.totalAds = 0,
    this.totalCommentsAuthor = 0,
    this.averageRatingAuthor = 0.0,
    this.ads = const [],
    this.currentPage = 1,
    this.totalPages = 1,
  });

  final int id;
  final String firstName;
  final String lastName;

  final String? phone;
  final String? avatar;
  final String? dateJoined;
  final int totalAds;
  final int totalCommentsAuthor;
  final double averageRatingAuthor;
  final List<AdSimilarEntity> ads;
  final int currentPage;
  final int totalPages;

  String get fullName {
    final nameStr = '$firstName $lastName'.trim();
    if (nameStr.isEmpty) return 'Foydalanuvchi';
    return nameStr;
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,

    phone,
    avatar,
    dateJoined,
    totalAds,
    totalCommentsAuthor,
    averageRatingAuthor,
    ads,
    currentPage,
    totalPages,
  ];
}
