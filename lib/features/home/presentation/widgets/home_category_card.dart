import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
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
    final isHighlighted = category.isHighlighted;
    final bgColor = isHighlighted ? AppColors.primary : AppColors.white;
    final borderColor = isHighlighted
        ? AppColors.primary
        : AppColors.cardBorderColor;
    final textColor = isHighlighted ? AppColors.white : AppColors.textPrimary;
    final innerBorder = isHighlighted
        ? Border.all(color: Colors.white, width: 2)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: category.onTap,
      child: Container(
        height: 126,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: innerBorder,
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 12,
                  top: 12,
                  right: 70,
                  bottom: 12,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      category.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: SizedBox(
                    width: 75,
                    height: category.asset.contains('apartment') ? 115 : 75,
                    child: category.asset.contains('car')
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi),
                            child: AppImage(
                              path: category.asset,
                              fit: BoxFit.fill,
                            ),
                          )
                        : AppImage(path: category.asset, fit: BoxFit.fill),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Grid layout
class HomeCategoriesGrid extends StatelessWidget {
  const HomeCategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: HomeCategoryCard(
                  category: HomeCategory(
                    title: 'Товары и\nпокупки',
                    asset: 'assets/images/shopping_basket.png',
                    isHighlighted: true,
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeCategoryCard(
                  category: HomeCategory(
                    title: 'Объекты\nстроительства',
                    asset: 'assets/images/building.png',
                    isHighlighted: false,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HomeCategoryCard(
                  category: HomeCategory(
                    title: 'Авто и\nмототехника',
                    asset: 'assets/images/car.png',
                    isHighlighted: false,
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeCategoryCard(
                  category: HomeCategory(
                    title: 'Услуги и\nработа',
                    asset: 'assets/images/tools.png',
                    isHighlighted: true,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
