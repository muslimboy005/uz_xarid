import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
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
import 'package:uz_xarid/features/product_list/presentation/widgets/product_filter_sheet.dart';
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
  // Top row: 'Mashhur' chip — independent from bottom row
  bool _popularSelected = false;
  // Bottom row: 1=Arzonroq, 2=Qimmatroq, 3=Yuqori reyting. null = none selected
  int? _bottomSortIndex;
  ProductFilterData? _activeFilter;

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
        widget.categoryId! <= 0) {
      return;
    }
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
      widget.subcategories.isNotEmpty
      ? widget.subcategories
      : _loadedSubcategories;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final filterParams = _buildFilterParams();

    final result = await getIt<GetProductList>()(
      GetProductListParams(
        searchQuery: widget.searchQuery,
        categoryId: widget.categoryId,
        listSource: widget.listSource,
        filterParams: filterParams,
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

  Map<String, dynamic> _buildFilterParams() {
    final params = <String, dynamic>{};

    // ── Sort ─────────────────────────────────────────────────────────────────
    switch (_bottomSortIndex) {
      case 1: // Arzonroq
        params['ordering'] = 'price';
        break;
      case 2: // Qimmatroq
        params['ordering'] = '-price';
        break;
      case 3: // Yuqori reyting
        params['ordering'] = '-rating';
        break;
      default:
        if (_popularSelected) params['ordering'] = '-view_count';
    }

    if (_activeFilter != null) {
      final f = _activeFilter!;

      // Price range
      if (f.minPrice != null) params['price_min'] = f.minPrice;
      if (f.maxPrice != null) params['price_max'] = f.maxPrice;

      // Toggles
      if (f.hasDiscount) params['has_discount'] = true;
      if (f.hasServices) params['listing_type'] = 'Service';

      // Seller type: Jismoniy shaxs=0 → is_physical=true; Biznes=1 → is_physical=false
      if (f.selectedSellerTypeIndex != null) {
        params['is_physical'] = f.selectedSellerTypeIndex == 0;
      }

      // Color: map index to color name string
      const colorNames = [
        'purple',
        'red',
        'pink',
        'sandy',
        'yellow',
        'blue',
        'lightblue',
        'green',
        'brown',
        'black',
        'black',
        'gray',
        'white',
      ];
      if (f.selectedColorIndex != null &&
          f.selectedColorIndex! < colorNames.length) {
        params['color'] = colorNames[f.selectedColorIndex!];
      }

      // Size: map index to size string
      const sizeNames = ['2XS', 'XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];
      if (f.selectedSizeIndex != null &&
          f.selectedSizeIndex! < sizeNames.length) {
        params['size'] = sizeNames[f.selectedSizeIndex!];
      }
    }

    return params;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    return Scaffold(
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
                // Always show 'Mashhur' at the top — it only selects/deselects itself
                _buildPopularChip(l10n),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    [1, 2, 3] // Skip 0 (Mashhur is in top row)
                        .map(
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildBottomSortChip(l10n, i),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
        if (hasSubcategories && !_loading) ...[
          SliverToBoxAdapter(child: _buildSubcategoriesStrip()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
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
                childAspectRatio: 0.54,
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

  Widget _buildBottomSortChip(AppLocalizations l10n, int index) {
    final labels = [
      l10n.sortPopular,
      l10n.sortCheaper,
      l10n.sortExpensive,
      l10n.sortHighRating,
    ];
    final label = labels[index];
    final isSelected = _bottomSortIndex == index;

    return Material(
      color: isSelected ? AppColors.primary : context.cardSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          setState(() {
            _bottomSortIndex = isSelected ? null : index;
          });
          _load();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : context.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// Always shows "Mashhur" in the top row — independent from bottom row
  Widget _buildPopularChip(AppLocalizations l10n) {
    return Material(
      color: _popularSelected ? AppColors.primary : context.cardSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          setState(() => _popularSelected = !_popularSelected);
          _load();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          child: Text(
            l10n.sortPopular,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _popularSelected ? AppColors.white : context.textPrimary,
            ),
          ),
        ),
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
          final query =
              'categoryId=${sub.id}&title=${Uri.encodeComponent(sub.name)}&categoryType=${Uri.encodeComponent(widget.categoryType)}';
          return _SubcategoryCard(
            item: sub,
            onTap: () => context.push('/products?$query'),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final appMode = context.watch<AppModeCubit>().state;
    final onHeader = appMode.onAppBarColor;
    return UzXaridAppBar(
      onSearchTap: () => context.push('/search'),
      onMenuTap: () {},
      actions: [
        GestureDetector(
          onTap: () async {
            final result = await showProductFilterSheet(
              context,
              initial: _activeFilter,
            );
            if (result != null) {
              setState(() => _activeFilter = result);
              _load(); // Reload with new filters
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: onHeader.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.filter_list, color: onHeader),
                if (_activeFilter != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
      buildWhen: (prev, curr) =>
          prev.isLiked(item.slug) != curr.isLiked(item.slug),
      builder: (context, likeState) {
        return ProductCard(
          slug: item.slug,
          title: item.title,
          color: context.cardSurface,
          height: 300,
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
