import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';

class HomeSubCategoryCard extends StatelessWidget {
  const HomeSubCategoryCard({super.key, required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.white;
    final borderColor = isDark ? AppColors.darkTextSecondary : AppColors.cardBorderColor;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              bottom: -6,
              left: -6,
              right: -6,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AppImage(path: category.image ?? '', fit: BoxFit.cover),
              ),
            ),
            Positioned(
              left: 6,
              right: 6,
              top: 16,
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 10,
                  height: 1.18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
