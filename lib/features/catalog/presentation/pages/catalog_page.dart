import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/shimmer_placeholders.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';
import 'package:uz_xarid/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:uz_xarid/features/catalog/presentation/widgets/catalog_category_tile.dart';
import 'package:uz_xarid/features/catalog/presentation/widgets/catalog_nav_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    this.initialCategoryType,
    this.initialCategoryId,
  });

  final String? initialCategoryType;
  final int? initialCategoryId;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  /// Har bir ota uchida faqat bitta bola ochiq: parentId -> ochiq bolaning id si. Root uchun key: null.
  final Map<int?, int?> _expandedByParentId = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final dividerColor = context.borderColor;

    return BlocProvider(
      create: (_) {
        final bloc = getIt<CatalogBloc>();
        if (widget.initialCategoryType != null &&
            widget.initialCategoryType!.isNotEmpty) {
          bloc.add(
            CatalogLoadRequested(
              categoryType: widget.initialCategoryType!,
              openCategoryId: widget.initialCategoryId,
            ),
          );
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: UzXaridAppBar(
          onSearchTap: () => context.push('/search'),
          onSearchChanged: (query) {
            // TODO: implement real search logic
          },
          onMenuTap: () {
            // TODO: open drawer or menu sheet
          },
        ),
        body: Container(
          color: bodyBg,
          height: MediaQuery.of(context).size.height,

          child: BlocBuilder<CatalogBloc, CatalogState>(
            builder: (context, state) {
              final slivers = <Widget>[];
              if (!state.showTypeTiles) {
                final entryCategoryName = _entryCategoryDisplayName(
                  state,
                  l10n,
                );
                final pathParts = [entryCategoryName];
                final trailingImagePath = _entryCategoryImagePath(state);
                final catalogBloc = context.read<CatalogBloc>();
                slivers.add(
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: CatalogNavBarDelegate(
                      pathParts: pathParts,
                      trailingImagePath: trailingImagePath,
                      onSegmentTap: (index) {
                        catalogBloc.add(CatalogPathSegmentTapped(index));
                      },
                      showBack: state.canGoBack,
                      onBack: state.canGoBack
                          ? () {
                              catalogBloc.add(const CatalogBackPressed());
                            }
                          : null,
                    ),
                  ),
                );
                slivers.add(
                  SliverToBoxAdapter(
                    child: Divider(height: 1, color: dividerColor),
                  ),
                );
              }
              slivers.addAll(_buildBodySlivers(context, state, l10n));
              return CustomScrollView(slivers: slivers);
            },
          ),
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

  /// Pathda ko‘rsatiladigan nom: kategoriyadan kirilgan bo‘lsa o‘sha kategoriya, yo‘qsa tur nomi.
  String _entryCategoryDisplayName(CatalogState state, AppLocalizations l10n) {
    if (state.stack.isNotEmpty) {
      return state.stack.last.displayName;
    }
    switch (state.categoryType) {
      case 'Product':
        return l10n.categoryGoods;
      case 'Home':
        return l10n.categoryConstruction;
      case 'Auto':
        return l10n.categoryAutoMoto;
      case 'Service':
        return l10n.categoryServices;
      default:
        return l10n.allCategories;
    }
  }

  /// Trailda ko‘rsatiladigan rasm: kategoriya rasmi yoki tur asseti.
  String? _entryCategoryImagePath(CatalogState state) {
    if (state.stack.isNotEmpty) {
      final img = state.stack.last.image;
      if (img != null && img.isNotEmpty) return img;
    }
    return _typeAssets[state.categoryType];
  }

  static const _typeAssets = {
    'Product': 'assets/images/backet.png',
    'Home': 'assets/images/apartment.png',
    'Auto': 'assets/images/car.png',
    'Service': 'assets/images/service.png',
  };

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
      delegate: SliverChildBuilderDelegate((context, index) {
        final e = types[index];
        final assetPath = _typeAssets[e.$2];
        return ListTile(
          leading: assetPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  child: AppImage(
                    path: assetPath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
          title: Text(
            e.$1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: context.textSecondary),
          onTap: () {
            bloc.add(CatalogLoadRequested(categoryType: e.$2));
          },
        );
      }, childCount: types.length),
    );
  }

  Widget _buildRootContentSliver(
    BuildContext context,
    CatalogState state,
    AppLocalizations l10n,
  ) {
    if (state.status == CatalogStatus.loading) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: const ShimmerListTile(height: 64),
            ),
            childCount: 8,
          ),
        ),
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
                      CatalogLoadRequested(categoryType: state.categoryType),
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
            style: TextStyle(color: context.textSecondary),
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
    final items = _buildExpandableCategoryItems(
      context,
      state,
      state.rootCategories,
      0,
      null,
      l10n,
    );
    return SliverList(delegate: SliverChildListDelegate(items));
  }

  /// Builds a flat list of tiles and dividers from categories tree; expanded nodes show children below (indented).
  /// [parentId]: bu ro'yxatning otasi (root uchun null); bir xil otadagi bolalardan faqat bittasi ochiq bo'ladi.
  List<Widget> _buildExpandableCategoryItems(
    BuildContext context,
    CatalogState state,
    List<CategoryEntity> categories,
    int indentLevel,
    int? parentId,
    AppLocalizations l10n,
  ) {
    final list = <Widget>[];
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final isExpanded = _expandedByParentId[parentId] == category.id;
      list.add(
        CatalogCategoryTile(
          category: category,
          indentLevel: indentLevel,
          isExpanded: isExpanded,
          onTap: () {
            if (category.hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedByParentId[parentId] = null;
                } else {
                  _expandedByParentId[parentId] = category.id;
                }
              });
            } else {
              context.push(
                '/products?categoryId=${category.id}&title=${Uri.encodeComponent(category.displayName)}&categoryType=${Uri.encodeComponent(state.categoryType)}',
              );
            }
          },
        ),
      );
      if (isExpanded && category.hasChildren) {
        final childIndent = indentLevel + 1;
        final horizontalPadding =
            AppDimens.paddingMedium + (childIndent * 16.0);
        list.add(
          Material(
            color: context.cardSurface,
            child: InkWell(
              onTap: () {
                final subcategories = category.children
                    .map(
                      (c) => {
                        'id': c.id,
                        'name': c.displayName,
                        'image': c.image,
                      },
                    )
                    .toList();
                context.push(
                  '/products?categoryId=${category.id}&title=${Uri.encodeComponent(category.displayName)}&categoryType=${Uri.encodeComponent(state.categoryType)}',
                  extra: subcategories,
                );
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: AppDimens.paddingMedium,
                  top: AppDimens.paddingSmall2,
                  bottom: AppDimens.paddingSmall2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.seeAll,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: context.textPrimary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        list.add(
          Divider(
            height: 1,
            indent: horizontalPadding,
            endIndent: AppDimens.paddingMedium,
            color: context.borderColor,
          ),
        );
        list.addAll(
          _buildExpandableCategoryItems(
            context,
            state,
            category.children,
            childIndent,
            category.id,
            l10n,
          ),
        );
      }
      if (i < categories.length - 1 || (isExpanded && category.hasChildren)) {
        list.add(
          Divider(
            height: 1,
            indent: AppDimens.paddingMedium + (indentLevel * 16.0),
            endIndent: AppDimens.paddingMedium,
            color: context.borderColor,
          ),
        );
      }
    }
    return list;
  }
}
