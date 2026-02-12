import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/features/home/data/datasources/home_category_api.dart';
import 'package:uz_xarid/features/home/data/repositories/home_category_repository_impl.dart';
import 'package:uz_xarid/features/home/domain/usecases/get_home_categories.dart';
import 'package:uz_xarid/features/home/presentation/bloc/home_category_bloc.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_category_card.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_subcategory_card.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      HomeCategory(
        title: l10n.categoryGoods,
        asset: 'assets/images/backet.png',
      ),
      HomeCategory(
        title: l10n.categoryConstruction,
        asset: 'assets/images/apartment.png',
      ),
      HomeCategory(
        title: l10n.categoryAutoMoto,
        asset: 'assets/images/car.png',
      ),
      HomeCategory(
        title: l10n.categoryServices,
        asset: 'assets/images/service.png',
      ),
    ];

    return BlocProvider(
      create: (_) {
        final dioClient = DioClient();
        final api = HomeCategoryApi(dioClient.dio);
        final repo = HomeCategoryRepositoryImpl(api);
        final useCase = GetHomeCategories(repo);
        return HomeCategoryBloc(useCase)..add(const HomeCategoriesRequested());
      },
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
                                onTap: () => context
                                    .read<HomeCategoryBloc>()
                                    .add(HomeCategorySelected(index)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  Card(
                    color: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.cardBorderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingMedium),

                      child: BlocBuilder<HomeCategoryBloc, HomeCategoryState>(
                        builder: (context, state) {
                          if (state.status == HomeCategoryStatus.loading &&
                              state.categories.isEmpty) {
                            return const Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

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

                          if (state.categories.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.categories.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                            itemBuilder: (context, index) {
                              final category = state.categories[index];
                              return HomeSubCategoryCard(category: category);
                            },
                          );
                        },
                      ),
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
