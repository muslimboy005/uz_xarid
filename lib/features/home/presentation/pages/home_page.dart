import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/products_not_found_placeholder.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/home/data/repositories/home_repository_impl.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home.dart';
import 'package:uz_xarid/features/home/presentation/bloc/home_bloc.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_banner_card.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_category_card.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_subcategory_card.dart';
import 'package:uz_xarid/features/home/presentation/widgets/recommendation_card.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:uz_xarid/core/widgets/shimmer_placeholders.dart';

Widget _servicesEmpty(BuildContext context, AppLocalizations l10n) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? AppColors.darkCard : AppColors.black50;
  final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  final textSecondary = isDark
      ? AppColors.darkTextSecondary
      : AppColors.textSecondary;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.settings, size: 48, color: textSecondary),
        const SizedBox(height: 12),
        Text(
          l10n.servicesEmptyTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.servicesEmptySubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textSecondary),
        ),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyBg = isDark ? AppColors.darkBackground : AppColors.background;
    final containerBg = isDark ? AppColors.darkCard : AppColors.black50;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final categories = [
      HomeCategory(
        title: l10n.categoryGoods,
        asset: 'assets/images/backet.png',
        categoryType: 'Product',
      ),
      HomeCategory(
        title: l10n.categoryConstruction,
        asset: 'assets/images/apartment.png',
        categoryType: 'Home',
      ),
      HomeCategory(
        title: l10n.categoryAutoMoto,
        asset: 'assets/images/car.png',
        categoryType: 'Auto',
      ),
      HomeCategory(
        title: l10n.categoryServices,
        asset: 'assets/images/service.png',
        categoryType: 'Service',
      ),
    ];

    return BlocProvider(
      create: (_) {
        final repo = HomeRepositoryImpl(homeApi: getIt<HomeApi>());
        final useCase = GetHome(repo);
        return HomeBloc(useCase)..add(const HomeRequested());
      },
      child: Scaffold(
        
        appBar: UzXaridAppBar(
          onSearchTap: () => context.push('/search'),
          onSearchChanged: (query) {},
          onMenuTap: () => context.push('/support-menu'),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: bodyBg,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.paddingLarge),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),

                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.homeHeadline,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              height: 1.1,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  SizedBox(
                    height: 90,
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingMedium,
                          ),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = index == state.selectedIndex;
                            return SizedBox(
                              width: 160,
                              child: HomeCategoryCard(
                                category: HomeCategory(
                                  title: category.title,
                                  asset: category.asset,
                                  isHighlighted: isSelected,
                                  categoryType: category.categoryType,
                                  onTap: () {
                                    final bloc = context.read<HomeBloc>();
                                    bloc.add(
                                      HomeCategorySelected(
                                        index,
                                        category.categoryType,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state.status == HomeStatus.failure) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            state.error ?? 'Xatolik yuz berdi',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.red),
                          ),
                        );
                      }

                      final isLoading =
                          state.status == HomeStatus.loading &&
                          state.categories.isEmpty;
                      final items = state.categories;

                      if (!isLoading && items.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      List<Widget> buildColumns(List<Widget> cards) {
                        final columnCount = (cards.length / 2).ceil();
                        return List.generate(columnCount, (index) {
                          final first = cards[index * 2];
                          final secondIndex = index * 2 + 1;
                          final second = secondIndex < cards.length
                              ? cards[secondIndex]
                              : null;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              first,
                              const SizedBox(height: 6),
                              ?second,
                            ],
                          );
                        });
                      }

                      const cardWidth = 92.0;
                      const cardHeight = 108.0;

                      final loadingCards = List.generate(
                        6,
                        (_) => const ShimmerCategoryCard(
                          width: cardWidth,
                          height: cardHeight,
                        ),
                      );

                      final dataCards = items
                          .map(
                            (c) => SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: InkWell(
                                onTap: () {
                                  final children =
                                      state.categoryIdToChildren[c.id] ?? [];
                                  final subcategories = children
                                      .map(
                                        (sub) => {
                                          'id': sub.id,
                                          'name': sub.name,
                                          'image': sub.image,
                                        },
                                      )
                                      .toList();
                                  const types = [
                                    'Product',
                                    'Home',
                                    'Auto',
                                    'Service',
                                  ];
                                  final ct = state.selectedIndex < types.length
                                      ? types[state.selectedIndex]
                                      : 'Product';
                                  context.push(
                                    '/products?categoryId=${c.id}&title=${Uri.encodeComponent(c.name)}&categoryType=${Uri.encodeComponent(ct)}',
                                    extra: subcategories,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: HomeSubCategoryCard(category: c),
                              ),
                            ),
                          )
                          .toList();

                      final columns = buildColumns(
                        isLoading ? loadingCards : dataCards,
                      );

                      return Container(
                        width: double.infinity,
                        height: cardHeight * 2 + 22,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: containerBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 19),
                          itemCount: columns.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (context, index) => columns[index],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state.status == HomeStatus.failure &&
                            state.banners.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              state.error ?? l10n.dataLoadError,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.red),
                            ),
                          );
                        }

                        if (state.status == HomeStatus.loading &&
                            state.banners.isEmpty) {
                          return const ShimmerBanner(
                            height: 240,
                            borderRadius: 20,
                          );
                        }

                        if (state.banners.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return SizedBox(
                          height: 270,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 1),
                            itemCount: state.banners.length,
                            padEnds: false,
                            itemBuilder: (context, index) {
                              final banner = state.banners[index];
                              return HomeBannerCard(banner: banner);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  ContainerW(
                    width: double.infinity,
                    // height: 420,
                    radius: 16,
                    color: context.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.recommendationsTitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                              ),
                              InkWell(
                                onTap: () => context.push(
                                  '/products?title=${Uri.encodeComponent(l10n.recommendationsTitle)}',
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      l10n.seeAll,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: textColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 290,
                            child: BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, state) {
                                if (state.status == HomeStatus.failure &&
                                    state.recommendations.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      state.error ?? l10n.dataLoadError,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: AppColors.red),
                                    ),
                                  );
                                }

                                if (state.status == HomeStatus.loading &&
                                    state.recommendations.isEmpty) {
                                  return ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemBuilder: (_, __) =>
                                        const ShimmerProductCard(width: 230),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemCount: 3,
                                  );
                                }

                                if (state.recommendations.isEmpty) {
                                  return ProductsNotFoundPlaceholder(
                                    l10n: l10n,
                                  );
                                }

                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,

                                  itemCount: state.recommendations.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) =>
                                      RecommendationCard(
                                        item: state.recommendations[index],
                                      ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  // Gifts section
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 329,
                          height: 460,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/rectangel.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 14,
                            bottom: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n.recommendationsTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 290,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    l10n.giftHeadline,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 290,
                                child: BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    if (state.status == HomeStatus.failure &&
                                        state.gifts.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          state.error ?? l10n.dataLoadError,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: AppColors.red),
                                        ),
                                      );
                                    }
                                    if (state.status == HomeStatus.loading &&
                                        state.gifts.isEmpty) {
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        itemBuilder: (_, __) =>
                                            const ShimmerProductCardSmall(
                                              width: 240,
                                            ),
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemCount: 2,
                                      );
                                    }
                                    if (state.gifts.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      itemCount: state.gifts.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 12),
                                      itemBuilder: (context, index) =>
                                          RecommendationCard(
                                            item: state.gifts[index],
                                          ),
                                    );
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () => context.push(
                                  '/products?title=${Uri.encodeComponent(l10n.giftHeadline)}&source=gifts',
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 15,
                                    right: 14,
                                    left: 10,
                                  ),
                                  width: 240,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue600,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.view,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.white,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  // Services section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.servicesTitle,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => context.push(
                            '/products?title=${Uri.encodeComponent(l10n.servicesTitle)}&source=services',
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.servicesSeeAll,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: textColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state.status == HomeStatus.failure &&
                            state.services.isEmpty) {
                          return _servicesEmpty(context, l10n);
                        }

                        if (state.status == HomeStatus.loading &&
                            state.services.isEmpty) {
                          return SizedBox(
                            height: 340,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: 4,
                              itemBuilder: (_, __) =>
                                  const ShimmerServiceCard(),
                            ),
                          );
                        }

                        if (state.services.isEmpty) {
                          return _servicesEmpty(context, l10n);
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: state.services.length,
                          itemBuilder: (context, index) =>
                              RecommendationCard(item: state.services[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
