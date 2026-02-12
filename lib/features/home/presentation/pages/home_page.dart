import 'package:flutter/material.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:uz_xarid/features/home/presentation/widgets/home_category_card.dart';
import 'package:uz_xarid/features/home/presentation/bloc/home_category_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      create: (_) => HomeCategoryBloc(),
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
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.homeHeadline,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  BlocBuilder<HomeCategoryBloc, HomeCategoryState>(
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
