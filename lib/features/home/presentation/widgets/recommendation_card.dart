import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/widgets/product_card.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';

/// Bitta tavsiya mahsulot karti — ichida umumiy [ProductCard] ishlatiladi.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.item});

  final HomeRecommendation item;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      buildWhen: (prev, curr) =>
          prev.isLiked(item.slug) != curr.isLiked(item.slug),
      builder: (context, likeState) {
        return ProductCard(
          slug: item.slug,
          title: item.title,
          mainImage: item.mainImage,
          price: item.price,
          finalPrice: item.finalPrice,
          currency: item.currency,
          rating: item.rating,
          reviewCount: item.reviewCount,
          width: 162,
          height: 220,
          isLiked: likeState.isLiked(item.slug),
          onLikeTap: () {
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
        );
      },
    );
  }
}
