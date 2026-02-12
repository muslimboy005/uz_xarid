import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/features/home/data/datasources/home_category_api.dart';
import 'package:uz_xarid/features/home/data/datasources/home_banner_api.dart';
import 'package:uz_xarid/features/home/data/repositories/home_banner_repository_impl.dart';
import 'package:uz_xarid/features/home/data/repositories/home_category_repository_impl.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home_banners.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home_categories.dart';
import 'package:uz_xarid/features/home/presentation/bloc/home_banner_cubit.dart';
import 'package:uz_xarid/features/home/presentation/bloc/home_category_bloc.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_banner_card.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_category_card.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_subcategory_card.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final dioClient = DioClient();
            final api = HomeCategoryApi(dioClient.dio);
            final repo = HomeCategoryRepositoryImpl(api);
            final useCase = GetHomeCategories(repo);
            return HomeCategoryBloc(useCase)
              ..add(const HomeCategoriesRequested());
          },
        ),
        BlocProvider(
          create: (_) {
            final dioClient = DioClient();
            final api = HomeBannerApi(dioClient.dio);
            final repo = HomeBannerRepositoryImpl(api);
            final useCase = GetHomeBanners(repo);
            return HomeBannerCubit(useCase)..fetchBanners();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: UzXaridAppBar(
          onSearchChanged: (query) {
            // TODO: implement real search logic
          },
          onMenuTap: () {
            // TODO: open drawer or menu sheet
          },
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: AppColors.background,
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
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),

                    child: BlocBuilder<HomeCategoryBloc, HomeCategoryState>(
                      builder: (context, state) {
                        return GridView.builder(
                          itemCount: categories.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.9,
                              ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = index == state.selectedIndex;
                            return HomeCategoryCard(
                              category: HomeCategory(
                                title: category.title,
                                asset: category.asset,
                                isHighlighted: isSelected,
                                categoryType: category.categoryType,
                                onTap: () {
                                  final bloc = context.read<HomeCategoryBloc>();
                                  bloc.add(HomeCategorySelected(index));
                                  bloc.add(
                                    HomeCategoriesRequested(
                                      categoryType: category.categoryType,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  BlocBuilder<HomeCategoryBloc, HomeCategoryState>(
                    builder: (context, state) {
                      if (state.status == HomeCategoryStatus.failure) {
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
                          state.status == HomeCategoryStatus.loading &&
                          state.categories.isEmpty;
                      final items = state.categories
                          .where((c) => c.name.trim().isNotEmpty)
                          .toList();

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
                              const SizedBox(height: 12),
                              if (second != null) second,
                            ],
                          );
                        });
                      }

                      const cardWidth = 150.0;
                      const cardHeight = 180.0;

                      final loadingCards = List.generate(
                        6,
                        (_) => Shimmer.fromColors(
                          baseColor: AppColors.black100,
                          highlightColor: AppColors.black50,
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.cardBorderColor,
                              ),
                            ),
                          ),
                        ),
                      );

                      final dataCards = items
                          .map(
                            (c) => SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: HomeSubCategoryCard(category: c),
                            ),
                          )
                          .toList();

                      final columns = buildColumns(
                        isLoading ? loadingCards : dataCards,
                      );

                      return SizedBox(
                        height: cardHeight * 2 + 16,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: columns.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
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
                    child: BlocBuilder<HomeBannerCubit, HomeBannerState>(
                      builder: (context, state) {
                        if (state.status == HomeBannerStatus.failure) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              state.error ?? 'Banner yuklashda xatolik',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.red),
                            ),
                          );
                        }

                        if (state.status == HomeBannerStatus.loading) {
                          return Shimmer.fromColors(
                            baseColor: AppColors.black100,
                            highlightColor: AppColors.black50,
                            child: Container(
                              height: 240,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
