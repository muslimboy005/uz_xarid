import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/products_not_found_placeholder.dart';
import 'package:uzxarid/core/widgets/product_card.dart';
import 'package:uzxarid/core/widgets/shimmer_placeholders.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uzxarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:uzxarid/features/product_list/domain/usecases/get_product_list.dart';
import 'package:uzxarid/features/product_list/domain/usecases/get_subcategories_by_category_id.dart';
import 'package:uzxarid/features/product_list/presentation/widgets/product_filter_sheet.dart';
import 'package:uzxarid/features/product_list/presentation/widgets/product_list_map_view.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class CategoryBreadcrumb {
  final String title;
  final List<SubcategoryItem> primarySubcategories;
  final int? activeChipId;
  final List<SubcategoryItem> secondarySubcategories;

  CategoryBreadcrumb({
    required this.title,
    required this.primarySubcategories,
    this.activeChipId,
    required this.secondarySubcategories,
  });
}

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
  final String? searchQuery;
  final int? categoryId;
  final String listSource;
  final List<SubcategoryItem> subcategories;
  final String categoryType;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductListItemEntity> _items = [];
  List<SubcategoryItem> _loadedSubcategories = [];
  List<SubcategoryItem> _primarySubcategories = [];
  List<SubcategoryItem> _secondarySubcategories = [];

  final List<CategoryBreadcrumb> _navigationStack = [];
  late String _currentTitle;

  int? _activeChipId;
  int? _activeCardId;

  bool _loading = true;
  String? _error;
  int _sortOption = 0;
  ProductFilterData? _activeFilter;
  bool _initialLoadDone = false;
  bool _mapViewMode = false;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _loadSubcategoriesIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      _load();
    }
  }

  Future<void> _loadSubcategoriesIfNeeded() async {
    if (widget.subcategories.isNotEmpty) return;
    if (widget.categoryId == null && widget.listSource != 'category') return;

    final result = await getIt<GetSubcategoriesByCategoryId>()(
      GetSubcategoriesByCategoryIdParams(
        categoryId: widget.categoryId,
        categoryType: widget.categoryType,
      ),
    );
    if (!mounted) return;
    if (result is Right<Failure, List<SubcategoryItem>>) {
      setState(() {
        _loadedSubcategories = result.right;
        if (_navigationStack.isEmpty) {
          _primarySubcategories = _loadedSubcategories;
        }
      });
    }
  }

  List<SubcategoryItem> get _effectiveSubcategories =>
      widget.subcategories.isNotEmpty
      ? widget.subcategories
      : _loadedSubcategories;

  String? get _activeSortValue {
    switch (_sortOption) {
      case 1:
        return ApiUrls.sortPopular;
      case 2:
        return ApiUrls.sortCheap;
      case 3:
        return ApiUrls.sortExpensive;
      case 4:
        return ApiUrls.sortHighRanking;
      default:
        return null;
    }
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });

    final mode = context.read<AppModeCubit>().state;
    final adType = mode == AppMode.buying ? 'Buy' : 'Sell';

    final filterId = _activeCardId ?? _activeChipId ?? widget.categoryId;

    final result = await getIt<GetProductList>()(
      GetProductListParams(
        searchQuery: widget.searchQuery,
        categoryId: filterId,
        listSource: widget.listSource,
        adType: adType,
        categoryType: widget.categoryType,
        filterParams: _buildFilterParams(),
        sort: _activeSortValue,
      ),
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result is Right) {
        _items = result.right;
        _error = null;
      } else {
        _error = (result as Left).left.message ?? l10n.dataLoadError;
      }
    });
  }

  Map<String, dynamic> _buildFilterParams() {
    final params = <String, dynamic>{};
    if (_activeFilter != null) {
      final f = _activeFilter!;
      if (f.minPrice != null) params['price_min'] = f.minPrice;
      if (f.maxPrice != null) params['price_max'] = f.maxPrice;
      if (f.hasDiscount) params['has_discount'] = true;
      if (f.hasServices) params['listing_type'] = 'Service';
      if (widget.categoryType == 'Auto') {
        if (f.onlyTop) params['is_top'] = true;
        if (f.vehicleMark != null) params['mark'] = f.vehicleMark;
        if (f.vehicleModel != null && f.vehicleModel!.trim().isNotEmpty) {
          params['model'] = f.vehicleModel!.trim();
        }
        if (f.yearFrom != null) params['manufacture_min'] = f.yearFrom;
        if (f.yearTo != null) params['manufacture_max'] = f.yearTo;
        if (f.probegFrom != null) params['probeg_min'] = f.probegFrom;
        if (f.probegTo != null) params['probeg_max'] = f.probegTo;
        if (f.engineCcFrom != null) {
          params['engine_capacity_min'] = f.engineCcFrom;
        }
        if (f.engineCcTo != null) params['engine_capacity_max'] = f.engineCcTo;
        if (f.enginePowerFrom != null) {
          params['engine_power_min'] = f.enginePowerFrom;
        }
        if (f.enginePowerTo != null) {
          params['engine_power_max'] = f.enginePowerTo;
        }
        if (f.vehicleFuelType != null) {
          params['fuel_type'] = f.vehicleFuelType;
        }
        if (f.vehicleTransmission != null) {
          params['transmission_type'] = f.vehicleTransmission;
        }
        if (f.vehiclePrivod != null) params['privod'] = f.vehiclePrivod;
        if (f.vehicleBody != null) params['body'] = f.vehicleBody;
        const autoColorNames = [
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
            f.selectedColorIndex! < autoColorNames.length) {
          params['color'] = autoColorNames[f.selectedColorIndex!];
        }
        if (f.vehicleConfiguration != null &&
            f.vehicleConfiguration!.trim().isNotEmpty) {
          params['configuration'] = f.vehicleConfiguration!.trim();
        }
        if (f.vehiclePaymentType != null) {
          params['payment_type'] = f.vehiclePaymentType;
        }
        if (f.selectedConditionIndex != null &&
            f.selectedConditionIndex! >= 0 &&
            f.selectedConditionIndex! < 3) {
          const condKeys = ['yangi', 'ishlatilgan', 'tamir_talab'];
          params['condition'] = condKeys[f.selectedConditionIndex!];
        }
      } else {
        if (f.selectedSellerTypeIndex != null) {
          params['is_physical'] = f.selectedSellerTypeIndex == 0;
        }
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
        const sizeNames = ['2XS', 'XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];
        if (f.selectedSizeIndex != null &&
            f.selectedSizeIndex! < sizeNames.length) {
          params['size'] = sizeNames[f.selectedSizeIndex!];
        }
      }
      params.addAll(f.dynamicFields);
    }
    return params;
  }

  bool _filterDataIsEmpty(ProductFilterData f) {
    if (widget.categoryType == 'Auto') {
      bool emptyStr(String? s) => s == null || s.trim().isEmpty;
      return f.minPrice == null &&
          f.maxPrice == null &&
          !f.hasDiscount &&
          !f.onlyTop &&
          f.selectedConditionIndex == null &&
          f.vehicleMark == null &&
          emptyStr(f.vehicleModel) &&
          f.yearFrom == null &&
          f.yearTo == null &&
          f.probegFrom == null &&
          f.probegTo == null &&
          f.engineCcFrom == null &&
          f.engineCcTo == null &&
          f.enginePowerFrom == null &&
          f.enginePowerTo == null &&
          f.vehicleFuelType == null &&
          f.vehicleTransmission == null &&
          f.vehiclePrivod == null &&
          f.vehicleBody == null &&
          f.selectedColorIndex == null &&
          emptyStr(f.vehicleConfiguration) &&
          f.vehiclePaymentType == null &&
          f.dynamicFields.isEmpty;
    }
    return f.minPrice == null &&
        f.maxPrice == null &&
        !f.hasDiscount &&
        !f.hasServices &&
        f.selectedConditionIndex == null &&
        f.selectedSellerTypeIndex == null &&
        f.selectedColorIndex == null &&
        f.selectedSizeIndex == null &&
        f.dynamicFields.isEmpty;
  }

  Future<void> _syncAutoPrimaryCategoryFromFilter(ProductFilterData? f) async {
    if (widget.categoryType != 'Auto' || f == null) return;
    final want = f.vehiclePrimaryCategoryId;
    if (want == _activeChipId) return;
    setState(() {
      _activeChipId = want;
      _activeCardId = null;
      _secondarySubcategories = [];
    });
    if (want == null) return;
    final result = await getIt<GetSubcategoriesByCategoryId>()(
      GetSubcategoriesByCategoryIdParams(
        categoryId: want,
        categoryType: widget.categoryType,
      ),
    );
    if (!mounted) return;
    if (result is Right<Failure, List<SubcategoryItem>>) {
      setState(() => _secondarySubcategories = result.right);
    }
  }

  Future<void> _openFilterSheet() async {
    final res = await showProductFilterSheet(
      context,
      initial: _activeFilter,
      vehicleListing: widget.categoryType == 'Auto',
      vehiclePrimaryCategories: _primarySubcategories,
      currentVehiclePrimaryCategoryId: _activeChipId,
      listingType: widget.categoryType,
      categoryId: _activeCardId ?? _activeChipId ?? widget.categoryId,
    );
    if (!mounted || res == null) return;

    if (res.clearedFilters) {
      setState(() => _activeFilter = null);
      _load();
      return;
    }

    if (res.openMapView) {
      final f = res.filter;
      await _syncAutoPrimaryCategoryFromFilter(f);
      if (!mounted) return;
      if (f != null) {
        final empty = _filterDataIsEmpty(f);
        setState(() {
          _activeFilter = empty ? null : f;
          _mapViewMode = true;
        });
      } else {
        setState(() => _mapViewMode = true);
      }
      _load();
      return;
    }

    final f = res.filter;
    await _syncAutoPrimaryCategoryFromFilter(f);
    if (!mounted) return;
    if (f != null) {
      final empty = _filterDataIsEmpty(f);
      setState(() => _activeFilter = empty ? null : f);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _mapViewMode ? null : _buildAppBar(context),
      body: Container(
        color: context.bodyBackground,
        height: MediaQuery.of(context).size.height,
        child: _error != null && !_loading
            ? _buildErrorBody(AppLocalizations.of(context)!)
            : _mapViewMode
            ? ProductListMapView(
                title: _currentTitle,
                items: _items,
                filterActive: _activeFilter != null,
                onBack: () => setState(() => _mapViewMode = false),
                onOpenFilters: _openFilterSheet,
              )
            : _buildBody(AppLocalizations.of(context)!),
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
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: _onBackTap,
                  color: context.textPrimary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Expanded(
                  child: Text(
                    _currentTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                _buildSortButton(context),
              ],
            ),
          ),
        ),
        if (hasSubcategories) ...[
          SliverToBoxAdapter(child: _buildSubcategoriesStrip()),
          if (_secondarySubcategories.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildSecondarySubcategoriesStrip()),
          ],
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

  Widget _buildSortButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final labels = [
      l10n.sortPopular,
      l10n.sortCheaper,
      l10n.sortExpensive,
      l10n.sortHighRating,
    ];
    final bool nonDefault = _sortOption != 0;
    final displayLabel = _sortOption == 0
        ? l10n.sortTitle
        : labels[_sortOption - 1];
    return PopupMenuButton<int>(
      color: context.cardSurface,
      onSelected: (value) {
        setState(() => _sortOption = (_sortOption == value) ? 0 : value);
        _load();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 44),
      itemBuilder: (_) => List.generate(
        labels.length,
        (i) => PopupMenuItem<int>(
          value: i + 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels[i],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: _sortOption == i + 1
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              if (_sortOption == i + 1)
                Icon(Icons.check_rounded, color: primaryColor, size: 18),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: nonDefault ? primaryColor : context.cardSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              displayLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: nonDefault ? Colors.white : context.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: nonDefault ? Colors.white : context.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesStrip() {
    final list = _primarySubcategories;
    final bool hasSelection = _activeChipId != null;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;

    if (hasSelection) {
      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final sub = list[index];
            final isSelected = _activeChipId == sub.id;
            return GestureDetector(
              onTap: () => _onPrimaryCategoryTap(sub),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : context.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryColor : context.borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    sub.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : context.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final sub = list[index];
          return _SubcategoryCard(
            item: sub,
            isSelected: _activeChipId == sub.id,
            onTap: () => _onPrimaryCategoryTap(sub),
          );
        },
      ),
    );
  }

  Widget _buildSecondarySubcategoriesStrip() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _secondarySubcategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final sub = _secondarySubcategories[index];
          final isSelected = _activeCardId == sub.id;
          return _SubcategoryCard(
            item: sub,
            isSelected: isSelected,
            onTap: () => _onSecondaryCategoryTap(sub),
          );
        },
      ),
    );
  }

  Future<void> _onPrimaryCategoryTap(SubcategoryItem sub) async {
    if (_activeChipId == sub.id) {
      setState(() {
        _activeChipId = null;
        _activeCardId = null;
        _secondarySubcategories = [];
        _loading = true;
      });
    } else {
      setState(() {
        _activeChipId = sub.id;
        _activeCardId = null;
        _secondarySubcategories = [];
        _loading = true;
      });

      final result = await getIt<GetSubcategoriesByCategoryId>()(
        GetSubcategoriesByCategoryIdParams(
          categoryId: sub.id,
          categoryType: widget.categoryType,
        ),
      );
      if (mounted && result is Right<Failure, List<SubcategoryItem>>) {
        setState(() => _secondarySubcategories = result.right);
      }
    }
    _load();
  }

  Future<void> _onSecondaryCategoryTap(SubcategoryItem sub) async {
    setState(() => _loading = true);

    final result = await getIt<GetSubcategoriesByCategoryId>()(
      GetSubcategoriesByCategoryIdParams(
        categoryId: sub.id,
        categoryType: widget.categoryType,
      ),
    );

    if (mounted &&
        result is Right<Failure, List<SubcategoryItem>> &&
        result.right.isNotEmpty) {
      // DRILL DOWN
      setState(() {
        // Find current active chip name for the new title
        final parentChip = _primarySubcategories.firstWhere(
          (c) => c.id == _activeChipId,
          orElse: () => sub,
        );

        _navigationStack.add(
          CategoryBreadcrumb(
            title: _currentTitle,
            primarySubcategories: List.from(_primarySubcategories),
            activeChipId: _activeChipId,
            secondarySubcategories: List.from(_secondarySubcategories),
          ),
        );

        _currentTitle = parentChip.name;
        _primarySubcategories = List.from(_secondarySubcategories);
        _activeChipId = sub.id;
        _activeCardId = null;
        _secondarySubcategories = result.right;
      });
    } else {
      // LEAF / FILTER
      setState(() {
        _activeCardId = (_activeCardId == sub.id) ? null : sub.id;
      });
    }
    _load();
  }

  void _onBackTap() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        final last = _navigationStack.removeLast();
        _currentTitle = last.title;
        _primarySubcategories = last.primarySubcategories;
        _activeChipId = last.activeChipId;
        _secondarySubcategories = last.secondarySubcategories;
        _activeCardId = null;
        _loading = true;
      });
      _load();
    } else {
      context.pop();
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final appMode = context.watch<AppModeCubit>().state;
    final onHeader = appMode.onAppBarColor;
    return UzXaridAppBar(
      onSearchTap: () => context.push('/search'),
      onMenuTap: () {},
      actions: [
        GestureDetector(
          onTap: _openFilterSheet,
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

  Widget _buildErrorBody(AppLocalizations l) {
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
            TextButton(onPressed: _load, child: Text(l.actionRetry)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProductListItemEntity item) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      buildWhen: (p, c) => p.isLiked(item.slug) != c.isLiked(item.slug),
      builder: (context, s) => ProductCard(
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
        isLiked: s.isLiked(item.slug),
        onLikeTap: () => context.read<FavoritesBloc>().add(
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
        ),
      ),
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  const _SubcategoryCard({
    required this.item,
    required this.onTap,
    this.isSelected = false,
  });
  final SubcategoryItem item;
  final VoidCallback onTap;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    return Material(
      color: isSelected ? primaryColor : context.cardSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : context.borderColor,
              width: isSelected ? 2 : 1,
            ),
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
                            color: isSelected
                                ? Colors.white
                                : context.textSecondary,
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
                      color: isSelected ? Colors.white : context.textPrimary,
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
