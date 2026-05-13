import 'package:flutter/material.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';

class HomeSubCategoryCard extends StatelessWidget {
  const HomeSubCategoryCard({super.key, required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.white;
    final borderColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.cardBorderColor;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    return SizedBox(
      width: 78,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AppImage(path: category.image ?? '', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
