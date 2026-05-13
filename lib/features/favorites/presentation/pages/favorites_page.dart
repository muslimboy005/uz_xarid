import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/product_card.dart';
import 'package:uzxarid/core/widgets/shimmer_placeholders.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final textColor = context.textSecondary;

    return Scaffold(
      appBar: UzXaridAppBar(
        onSearchChanged: (query) {
          // TODO: implement favorites search or filter
        },
        onMenuTap: () {
          // TODO: open favorites menu
        },
      ),
      body: Container(
        color: bodyBg,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: ContainerW(
                        color: context.cardSurface,
                        radius: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      text: l10n.favoritesTitle,
                      fontSize: 22,
                      fontWeight: 700,
                      color: context.textPrimary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    if (state.status == FavoritesStatus.loading &&
                        state.list.isEmpty) {
                      return _buildShimmerGrid();
                    }
                    if (state.status == FavoritesStatus.failure &&
                        state.list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.paddingLarge),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.error ?? l10n.favoritesBody,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textColor),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  context.read<FavoritesBloc>().add(
                                    const FavoritesLoadListRequested(),
                                  );
                                },
                                child: Text(l10n.actionRetry),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state.list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 68,
                              color: textColor.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l10n.favoritesEmptyTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.paddingLarge,
                              ),
                              child: Text(
                                l10n.favoritesEmptySubtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: textColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FavoritesBloc>().add(
                          const FavoritesLoadListRequested(
                            page: 1,
                            pageSize: 8,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingMedium,
                          vertical: AppDimens.paddingSmall,
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.54,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: state.list.length,
                          itemBuilder: (context, index) {
                            final item = state.list[index];
                            return _FavoriteCard(item: item);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: AppDimens.paddingSmall,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.54,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerGridProductCard(),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item});

  final FavoriteItemEntity item;

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
      isLiked: true,
      onLikeTap: () {
        context.read<FavoritesBloc>().add(
          FavoritesToggleRequested(adSlug: item.slug),
        );
      },
    );
  }
}
