import 'package:flutter/material.dart';
import 'package:uz_xarid/core/widgets/product_card.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';

/// Bitta tavsiya mahsulot karti — ichida umumiy [ProductCard] ishlatiladi.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.item});

  final HomeRecommendation item;

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      slug: item.slug,
      title: item.title,
      mainImage: item.mainImage,
      price: item.price,
      finalPrice: item.finalPrice,
      currency: item.currency,
      rating: item.rating,
      reviewCount: item.reviewCount,
      width: 240,
      height: 310,
    );
  }
}
