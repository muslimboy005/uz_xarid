import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/products_not_found_placeholder.dart';
import 'package:uz_xarid/core/widgets/product_card.dart';
import 'package:uz_xarid/core/widgets/shimmer_placeholders.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uz_xarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:uz_xarid/features/product_list/domain/usecases/get_product_list.dart';
import 'package:uz_xarid/features/product_list/domain/usecases/get_subcategories_by_category_id.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

/// Barcha joylardan ochiladigan mahsulotlar ro'yxati (Barchasi, turkum bo'yicha).
class ProductListPage extends StatefulWidget {
  const ProductListPage({
    super.key,
    required this.title,
    this.searchQuery,
    this.categoryId,
    this.listSource = 'recommendations',
    this.subcategories = const [],
    this.categoryType = 'Product',
  });

  final String title;
  /// Qidiruv so'rovi – berilsa ads/search orqali yuklanadi.
  final String? searchQuery;
  final int? categoryId;

  /// 'recommendations' | 'services' – bosh sahifa "Barchasi" bo'limi.
  final String listSource;

  /// Ostki turkumlar – bo'lsa tepada gorizontal scroll qatorida ko'rsatiladi.
  final List<SubcategoryItem> subcategories;

  /// Product | Auto | Home | Service – subkategoriyalarni yuklash uchun (strip bo'sh bo'lsa).
  final String categoryType;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductListItemEntity> _items = [];
  List<SubcategoryItem> _loadedSubcategories = [];
  bool _loading = true;
  String? _error;
  int _selectedSortIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadSubcategoriesIfNeeded();
  }

  /// categoryId bor, subcategories bo'sh va categoryType bor bo'lsa – daraxtdan bolalarni yuklaydi.
  Future<void> _loadSubcategoriesIfNeeded() async {
    if (widget.subcategories.isNotEmpty ||
        widget.categoryId == null ||
        widget.categoryId! <= 0) return;
    final result = await getIt<GetSubcategoriesByCategoryId>()(
      GetSubcategoriesByCategoryIdParams(
        categoryId: widget.categoryId!,
        categoryType: widget.categoryType,
      ),
    );
    if (!mounted) return;
    if (result is Right<Failure, List<SubcategoryItem>>) {
      setState(() => _loadedSubcategories = result.right);
    }
  }

  List<SubcategoryItem> get _effectiveSubcategories =>
      widget.subcategories.isNotEmpty ? widget.subcategories : _loadedSubcategories;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await getIt<GetProductList>()(
      GetProductListParams(
        searchQuery: widget.searchQuery,
        categoryId: widget.categoryId,
        listSource: widget.listSource,
      ),
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result is Right) {
        _items = result.right;
        _error = null;
      } else {
        _error = (result as Left).left.message ?? 'Xatolik';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(context),
      body: Container(
        color: bodyBg,
        height: MediaQuery.of(context).size.height,
        child: _error != null && !_loading
            ? _buildErrorBody(l10n)
            : _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final hasSubcategories = _effectiveSubcategories.isNotEmpty;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => context.pop(),
                  color: context.textPrimary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasSubcategories && !_loading) ...[
          SliverToBoxAdapter(child: _buildSubcategoriesStrip()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
        SliverToBoxAdapter(child: _buildFilterAndSortRow(l10n)),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (_loading)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.48,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ShimmerGridProductCard(),
                childCount: 6,
              ),
            ),
          )
        else if (_items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: ProductsNotFoundPlaceholder(l10n: l10n),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.48,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCard(context, _items[index]),
                childCount: _items.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterAndSortRow(AppLocalizations l10n) {
    final sortLabels = [
      l10n.sortPopular,
      l10n.sortCheaper,
      l10n.sortExpensive,
      l10n.sortHighRating,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 20),
              label: Text(l10n.productListFilters),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.borderColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sortLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = _selectedSortIndex == index;
                return Material(
                  color: selected ? AppColors.primary : context.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSortIndex = index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Text(
                        sortLabels[index],
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.white
                              : context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesStrip() {
    final list = _effectiveSubcategories;
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final sub = list[index];
          final query = 'categoryId=${sub.id}&title=${Uri.encodeComponent(sub.name)}&categoryType=${Uri.encodeComponent(widget.categoryType)}';
          return _SubcategoryCard(
            item: sub,
            onTap: () => context.push('/products?$query'),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return UzXaridAppBar(
      onSearchTap: () => context.push('/search'),
      onMenuTap: () {},
    );
  }

  Widget _buildErrorBody(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              text: _error!,
              style: const TextStyle(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _load, child: Text(l10n.actionRetry)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProductListItemEntity item) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      buildWhen: (prev, curr) => prev.isLiked(item.slug) != curr.isLiked(item.slug),
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

class _SubcategoryCard extends StatelessWidget {
  const _SubcategoryCard({required this.item, required this.onTap});

  final SubcategoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: item.image != null && item.image!.isNotEmpty
                      ? AppImage(path: item.image!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.category_outlined,
                            size: 32,
                            color: context.textSecondary,
                          ),
                        ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
