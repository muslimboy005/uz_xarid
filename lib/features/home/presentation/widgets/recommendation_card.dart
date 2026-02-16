import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.item});

  final HomeRecommendation item;

  String _formatPrice(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.split('.').first.replaceAll(RegExp(r'(?=(\\d{3})+(?!\\d))'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final currentPrice = _formatPrice(item.finalPrice ?? item.price);
    final oldPrice = item.finalPrice != null ? _formatPrice(item.price) : '';
    return Container(
      width: 240,
      height: 310,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 136,
                width: double.infinity,
                child: AppImage(
                  path: item.mainImage ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 22,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chat_bubble_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${item.reviewCount} ${AppLocalizations.of(context)!.reviewsLabel}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (oldPrice.isNotEmpty)
                    Text(
                      '$oldPrice ${item.currency}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    currentPrice.isNotEmpty ? '$currentPrice ${item.currency}' : '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Text(
                  AppLocalizations.of(context)!.view,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
