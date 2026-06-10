import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';

class RecommendationListCard extends StatelessWidget {
  const RecommendationListCard({
    super.key,
    required this.item,
  });

  final HomeRecommendation item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.white;

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      buildWhen: (prev, curr) =>
          prev.isLiked(item.slug) != curr.isLiked(item.slug),
      builder: (context, likeState) {
        return InkWell(
          onTap: () => context.push('/product/${item.slug}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: item.mainImage != null
                          ? AppImage(
                              path: item.mainImage!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.background,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Rating
                        Row(
                          children: [
                            if (item.rating > 0)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: AppImage(
                                      path: AppAssets.star,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${item.reviewCount})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Ombor mavjud',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryTextColor,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.finalPrice != null &&
                                      item.finalPrice != item.price)
                                    Text(
                                      '${item.price} ${item.currency}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: secondaryTextColor,
                                        decoration:
                                            TextDecoration.lineThrough,
                                      ),
                                    ),
                                  Text(
                                    '${item.finalPrice ?? item.price} ${item.currency}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<FavoritesBloc>().add(
                                  FavoritesToggleRequested(
                                    adSlug: item.slug,
                                    adForLocal: FavoriteItemEntity(
                                      slug: item.slug,
                                      title: item.title,
                                      mainImage: item.mainImage,
                                      price: item.price,
                                      finalPrice: item.finalPrice,
                                      currency: item.currency,
                                      rating: item.rating,
                                      reviewCount: item.reviewCount,
                                      isLiked: true,
                                    ),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(
                                  likeState.isLiked(item.slug)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_outline_rounded,
                                  size: 20,
                                  color: likeState.isLiked(item.slug)
                                      ? AppColors.red
                                      : secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
