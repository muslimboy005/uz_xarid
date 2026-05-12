
import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';

class HomeCategory {
  const HomeCategory({
    required this.title,
    required this.asset,
    this.onTap,
    this.isHighlighted = false,
    this.categoryType = 'Product',
  });

  final String title;
  final String asset;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final String categoryType;
}

class HomeCategoryCard extends StatelessWidget {
  const HomeCategoryCard({super.key, required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = category.isHighlighted;
    final primary = context.primaryColor;
    final bgColor = isSelected
        ? primary
        : (isDark ? AppColors.darkCard : AppColors.white);
    final textColor = isSelected
        ? AppColors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: category.onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.cardBorderColor),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 13.5 : 15),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: category.asset.contains('car') ? 0 : -12,
                bottom: -12,
                child: SizedBox(
                  width: 100,
                  height: category.asset.contains('apartment') ? 115 : 100,
                  child:
                      // category.asset.contains('car')
                      //     ? Transform(
                      //         alignment: Alignment.center,
                      //         transform: Matrix4.rotationY(pi),
                      //         child: AppImage(
                      //           path: category.asset,
                      //           fit: BoxFit.contain,
                      //         ),
                      //       )
                      //     :
                      AppImage(path: category.asset, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                right: 12,
                child: Text(
                  category.title,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
