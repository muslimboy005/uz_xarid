import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:uz_xarid/features/catalog/presentation/widgets/catalog_category_tile.dart';
import 'package:uz_xarid/features/catalog/presentation/widgets/catalog_nav_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<CatalogBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: UzXaridAppBar(
          onSearchChanged: (query) {
            // TODO: implement real search logic
          },
          onMenuTap: () {
            // TODO: open drawer or menu sheet
          },
        ),
        body: BlocBuilder<CatalogBloc, CatalogState>(
          builder: (context, state) {
            final slivers = <Widget>[];
            if (!state.showTypeTiles) {
              final navTitle = state.stack.isNotEmpty
                  ? state.stack.last.displayName
                  : l10n.allCategories;
              slivers.add(
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CatalogNavBarDelegate(
                    title: navTitle,
                    showBack: state.canGoBack,
                    onBack: state.canGoBack
                        ? () {
                            context
                                .read<CatalogBloc>()
                                .add(const CatalogBackPressed());
                          }
                        : null,
                  ),
                ),
              );
              slivers.add(
                SliverToBoxAdapter(
                  child: Divider(
                    height: 1,
                    color: AppColors.cardBorderColor,
                  ),
                ),
              );
            }
            slivers.addAll(_buildBodySlivers(context, state, l10n));
            return CustomScrollView(slivers: slivers);
          },
        ),
      ),
    );
  }

  List<Widget> _buildBodySlivers(
    BuildContext context,
    CatalogState state,
    AppLocalizations l10n,
  ) {
    if (state.showTypeTiles) {
      return [_buildTypeTilesSliver(context, state, l10n)];
    }
    if (state.stack.isNotEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: _buildCategoryListSliver(context, state, l10n),
        ),
      ];
    }
    final content = _buildRootContentSliver(context, state, l10n);
    if (content is SliverFillRemaining) {
      return [content];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.only(bottom: 24),
        sliver: content,
      ),
    ];
  }

  void _onCategoryTap(BuildContext context, CategoryEntity category) {
    context.read<CatalogBloc>().add(CatalogCategorySelected(category));
  }

  Widget _buildTypeTilesSliver(
    BuildContext context,
    CatalogState state,
    AppLocalizations l10n,
  ) {
    final bloc = context.read<CatalogBloc>();
    final types = [
      (l10n.categoryGoods, 'Product'),
      (l10n.categoryConstruction, 'Home'),
      (l10n.categoryAutoMoto, 'Auto'),
      (l10n.categoryServices, 'Service'),
    ];
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final e = types[index];
          return ListTile(
            title: Text(
              e.$1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              bloc.add(CatalogLoadRequested(categoryType: e.$2));
            },
          );
        },
        childCount: types.length,
      ),
    );
  }

  Widget _buildRootContentSliver(
    BuildContext context,
    CatalogState state,
    AppLocalizations l10n,
  ) {
    if (state.status == CatalogStatus.loading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == CatalogStatus.failure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: state.error ?? l10n.dataLoadError,
                  style: const TextStyle(color: AppColors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.read<CatalogBloc>().add(
                          CatalogLoadRequested(
                            categoryType: state.categoryType,
                          ),
                        );
                  },
                  child: Text(l10n.actionRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final list = state.currentList;
    if (list.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: AppText(
            text: l10n.catalogBody,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _buildCategoryListSliver(context, state, l10n);
  }

  Widget _buildCategoryListSliver(
    BuildContext context,
    CatalogState state,
    AppLocalizations l10n,
  ) {
    final list = state.currentList;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = list[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatalogCategoryTile(
                category: category,
                onTap: () => _onCategoryTap(context, category),
              ),
              if (index < list.length - 1)
                Divider(
                  height: 1,
                  indent: AppDimens.paddingMedium,
                  endIndent: AppDimens.paddingMedium,
                  color: AppColors.cardBorderColor,
                ),
            ],
          );
        },
        childCount: list.length,
      ),
    );
  }
}
