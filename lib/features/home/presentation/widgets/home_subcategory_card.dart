import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';

class HomeSubCategoryCard extends StatelessWidget {
  const HomeSubCategoryCard({super.key, required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderColor),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            bottom: -10,
            left: -10,
            right: -10,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: AppImage(path: category.image ?? '', fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 10,
            child: Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
