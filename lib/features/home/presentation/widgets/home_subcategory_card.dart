import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/home/domain/entities/category_entity.dart';

class HomeSubCategoryCard extends StatelessWidget {
  const HomeSubCategoryCard({super.key, required this.category});

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderColor),
      ),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
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
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomCenter,

            child: SizedBox(
              height: 120,
              width: 150,
              child: AppImage(path: category.image ?? '', fit: BoxFit.fill),
            ),
          ),
        ],
      ),
    );
  }
}
