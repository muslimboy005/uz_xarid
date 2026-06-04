import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/features/home/data/datasources/home_api.dart';
import 'package:uzxarid/features/home/data/repositories/home_repository_impl.dart';
import 'package:uzxarid/features/home/domain/usecases/get_home.dart';
import 'package:uzxarid/features/home/presentation/bloc/home_bloc.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/features/home/presentation/widgets/recommendation_card.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_event.dart';
import 'package:uzxarid/l10n/app_localizations.dart';
import 'package:uzxarid/core/utils/responsive.dart';
import 'package:uzxarid/core/widgets/shimmer_placeholders.dart';

class _HomeCategoryData {
  const _HomeCategoryData({
    required this.title,
    required this.asset,
    required this.categoryType,
  });

  final String title;
  final String asset;
  final String categoryType;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // Refresh the notification bell badge each time home opens.
    context.read<NotificationBloc>().add(
      const NotificationBadgeLoadRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyBg = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final categories = <_HomeCategoryData>[
      _HomeCategoryData(
        title: l10n.categoryGoods,
        asset: 'assets/images/backet.png',
        categoryType: 'Product',
      ),
      _HomeCategoryData(
        title: l10n.categoryConstruction,
        asset: 'assets/images/apartment.png',
        categoryType: 'Home',
      ),
      _HomeCategoryData(
        title: l10n.categoryAutoMoto,
        asset: 'assets/images/car.png',
        categoryType: 'Auto',
      ),
      _HomeCategoryData(
        title: l10n.categoryServices,
        asset: 'assets/images/service.png',
        categoryType: 'Service',
      ),
      _HomeCategoryData(
        title: l10n.categoryEquipment,
        asset: 'assets/images/equipments.png',
        categoryType: 'Equipment',
      ),
    ];

    return BlocProvider(
      create: (context) {
        final mode = context.read<AppModeCubit>().state;
        final adType = mode == AppMode.buying ? 'Buy' : 'Sell';
        final repo = HomeRepositoryImpl(homeApi: getIt<HomeApi>());
        final useCase = GetHome(repo);
        return HomeBloc(useCase)
          ..add(HomeRequested(adType: adType, pageSize: 16));
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppModeCubit, AppMode>(
            listener: (context, mode) {
              final adType = mode == AppMode.buying ? 'Buy' : 'Sell';
              context.read<HomeBloc>().add(
                HomeRequested(adType: adType, pageSize: 16),
              );
            },
          ),
          BlocListener<CurrencyCubit, CurrencyState>(
            listenWhen: (prev, curr) => prev.selectedCcy != curr.selectedCcy,
            listener: (context, _) {
              final adType =
                  context.read<AppModeCubit>().state == AppMode.buying
                  ? 'Buy'
                  : 'Sell';
              context.read<HomeBloc>().add(
                HomeRequested(adType: adType, pageSize: 16),
              );
            },
          ),
        ],
        child: UzXaridScaffold(
          backgroundColor: bodyBg,
          trailing: _HomeMenuButton(),
          floatingHeaderHeight: AppResponsive.homeFloatingHeaderHeight(context),
          floatingHeader: Padding(
            padding: EdgeInsets.fromLTRB(
              AppResponsive.horizontalPadding(context),
              2,
              AppResponsive.horizontalPadding(context),
              4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeModeSegmented(l10n: l10n),
                const SizedBox(height: 8),
                UzXaridSearchField(
                  hintText: l10n.searchHint,
                  onTap: () => context.push('/search'),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: AppDimens.paddingMedium,
                //   ),
                //   child: Text(
                //     l10n.homeHeadline,
                //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //       fontWeight: FontWeight.w800,
                //       color: textColor,
                //       fontSize: 20,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 4),
                // Horizontal category cards
                SizedBox(
                  height: AppResponsive.homeCategoryListHeight(context),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.horizontalPadding(context),
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 5),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return _HomeCategoryTile(
                        title: cat.title,
                        asset: cat.asset,
                        tileSize: AppResponsive.homeCategoryTileSize(context),
                        isSelected: _selectedCategoryIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                          context.push(
                            '/products?title=${Uri.encodeComponent(cat.title)}&categoryType=${cat.categoryType}&source=category',
                          );
                        },
                      );
                    },
                  ),
                ),
                // Recommendations grid
                const Divider(thickness: 2),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.horizontalPadding(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.recommendationsTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.horizontalPadding(context),
                  ),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state.status == HomeStatus.failure &&
                          state.recommendations.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            state.error ?? l10n.dataLoadError,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.red),
                          ),
                        );
                      }

                      if ((state.status == HomeStatus.initial ||
                              state.status == HomeStatus.loading) &&
                          state.recommendations.isEmpty) {
                        return GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: AppResponsive.productGridDelegate(
                            context,
                            showCartButton: true,
                          ),
                          itemCount: 4,
                          itemBuilder: (_, _) => const ShimmerGridProductCard(),
                        );
                      }

                      if (state.recommendations.isEmpty) {
                        return _SectionEmptyCard(
                          icon: Icons.inventory_2_outlined,
                          message: l10n.productsNotFoundTitle,
                        );
                      }

                      final items = state.recommendations;
                      final hasOdd = items.length.isOdd;
                      return GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: AppResponsive.productGridDelegate(
                          context,
                          showCartButton: true,
                        ),
                        itemCount: items.length + (hasOdd ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= items.length) {
                            return _SeeAllTile(
                              label: l10n.seeAll,
                              caption: l10n.recommendationsTitle,
                              onTap: () => context.push(
                                '/products?title=${Uri.encodeComponent(l10n.recommendationsTitle)}',
                              ),
                            );
                          }
                          return RecommendationCard(
                            item: items[index],
                            showCartButton: true,
                            width: null,
                            height: null,
                          );
                        },
                      );
                    },
                  ),
                ),
                // Gifts section — title always visible. Body switches
                // between shimmer, real grid, or compact empty card.
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingMedium,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.giftHeadline,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => context.push(
                              '/products?title=${Uri.encodeComponent(l10n.giftHeadline)}&source=gifts',
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
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingMedium,
                      ),
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          final isLoading =
                              state.status == HomeStatus.initial ||
                              state.status == HomeStatus.loading;
                          final items = state.gifts;
                          if (isLoading && items.isEmpty) {
                            return GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: AppResponsive.productGridDelegate(
                                context,
                                showCartButton: true,
                              ),
                              itemCount: 4,
                              itemBuilder: (_, _) =>
                                  const ShimmerGridProductCard(),
                            );
                          }
                          if (items.isEmpty) {
                            return _SectionEmptyCard(
                              icon: Icons.card_giftcard_outlined,
                              message: l10n.productsNotFoundTitle,
                            );
                          }
                          final hasOdd = items.length.isOdd;
                          return GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: AppResponsive.productGridDelegate(
                              context,
                              showCartButton: true,
                            ),
                            itemCount: items.length + (hasOdd ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= items.length) {
                                return _SeeAllTile(
                                  label: l10n.seeAll,
                                  caption: l10n.giftHeadline,
                                  onTap: () => context.push(
                                    '/products?title=${Uri.encodeComponent(l10n.giftHeadline)}&source=gifts',
                                  ),
                                );
                              }
                              return RecommendationCard(
                                item: items[index],
                                showCartButton: true,
                                width: null,
                                height: null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Services
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.servicesTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state.status == HomeStatus.failure &&
                          state.services.isEmpty) {
                        return _SectionEmptyCard(
                          icon: Icons.handyman_outlined,
                          message: l10n.servicesEmptyTitle,
                        );
                      }

                      if ((state.status == HomeStatus.initial ||
                              state.status == HomeStatus.loading) &&
                          state.services.isEmpty) {
                        return GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: AppResponsive.productGridDelegate(
                            context,
                            showCartButton: true,
                          ),
                          itemCount: 4,
                          itemBuilder: (_, _) => const ShimmerServiceCard(),
                        );
                      }

                      if (state.services.isEmpty) {
                        return _SectionEmptyCard(
                          icon: Icons.handyman_outlined,
                          message: l10n.servicesEmptyTitle,
                        );
                      }

                      final items = state.services;
                      final hasOdd = items.length.isOdd;
                      return GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: AppResponsive.productGridDelegate(
                          context,
                          showCartButton: true,
                        ),
                        itemCount: items.length + (hasOdd ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= items.length) {
                            return _SeeAllTile(
                              label: l10n.servicesSeeAll,
                              caption: l10n.servicesTitle,
                              onTap: () => context.push(
                                '/products?title=${Uri.encodeComponent(l10n.servicesTitle)}&source=services',
                              ),
                            );
                          }
                          return RecommendationCard(
                            item: items[index],
                            showCartButton: true,
                            width: null,
                            height: null,
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height:
                      AppDimens.bottomNavClearance +
                      MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCategoryTile extends StatelessWidget {
  const _HomeCategoryTile({
    required this.title,
    required this.asset,
    required this.tileSize,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String asset;
  final double tileSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.primaryColor;
    final unselectedBg = isDark ? AppColors.darkCard : AppColors.white;
    final textColor = isSelected
        ? primary
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final outerBorderColor = isSelected
        ? primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.cardBorderColor);

    final labelSize = tileSize < 66 ? 9.0 : 10.0;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: SizedBox(
        width: tileSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: tileSize,
              height: tileSize,
              padding: EdgeInsets.all(isSelected ? 4 : 0),
              decoration: BoxDecoration(
                color: isSelected ? unselectedBg : unselectedBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: outerBorderColor,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? primary : unselectedBg,
                  borderRadius: BorderRadius.circular(isSelected ? 13.5 : 15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isSelected ? 13.5 : 15),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -6,
                        top: 4,
                        child: AppImage(path: asset, fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onHeader = context.watch<AppModeCubit>().state.onAppBarColor;
    return InkWell(
      onTap: () => context.push('/support-menu'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onHeader.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.menu_rounded, color: onHeader, size: 22),
      ),
    );
  }
}

class _SectionEmptyCard extends StatelessWidget {
  const _SectionEmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.textSecondary.withValues(alpha: 0.18),
                  context.textSecondary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: context.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeAllTile extends StatelessWidget {
  const _SeeAllTile({
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 220.0;
              final imageHeight = (cardHeight * 0.55).clamp(
                80.0,
                cardHeight - 80,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha: 0.20),
                            accent.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
