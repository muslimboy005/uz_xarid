import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/either/either.dart';
import 'package:uz_xarid/core/error/failures.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/product_card.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uz_xarid/features/product_list/domain/usecases/get_product_list.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

/// Qidiruv ekrani: har harfda qidiruv natijalari, pastda "Sizga tavsiya qilamiz".
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const List<String> _frequentSearches = ['iphone', 'noutbuk', 'kompu'];
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();

  List<ProductListItemEntity> _searchResults = [];
  bool _searchLoading = false;
  List<ProductListItemEntity> _recommendations = [];
  bool _recommendationsLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }
    _debounceTimer = Timer(_searchDebounce, () {
      final current = _searchController.text.trim();
      if (current.isNotEmpty) _runSearch(current);
    });
    setState(() => _searchLoading = true);
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searchLoading = true);
    final result = await getIt<GetProductList>()(
      GetProductListParams(searchQuery: query, pageSize: 200),
    );
    if (!mounted) return;
    setState(() {
      _searchLoading = false;
      _searchResults = result is Right<Failure, List<ProductListItemEntity>>
          ? result.right
          : [];
    });
  }

  Future<void> _loadRecommendations() async {
    setState(() => _recommendationsLoading = true);
    // Avval 'Buy', bo'sh bo'lsa 'Sell' tavsiyalarni yuklash
    var result = await getIt<GetProductList>()(
      const GetProductListParams(
        listSource: 'recommendations',
        pageSize: 20,
        adType: 'Buy',
      ),
    );
    var list = result is Right<Failure, List<ProductListItemEntity>>
        ? result.right
        : <ProductListItemEntity>[];
    if (list.isEmpty) {
      result = await getIt<GetProductList>()(
        const GetProductListParams(
          listSource: 'recommendations',
          pageSize: 20,
          adType: 'Sell',
        ),
      );
      list = result is Right<Failure, List<ProductListItemEntity>>
          ? result.right
          : [];
    }
    if (!mounted) return;
    setState(() {
      _recommendationsLoading = false;
      _recommendations = list;
    });
  }

  void _setSearchQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    _onSearchTextChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    return Scaffold(
      backgroundColor: context.bodyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
              child: _buildSearchField(context, l10n),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                children: [
                  Text(
                    l10n.searchFrequentlySearched,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFrequentChips(context),
                  const SizedBox(height: 16),
                  if (_searchController.text.trim().isNotEmpty) ...[
                    _buildSearchResultsSection(textColor),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    l10n.recommendationsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRecommendationsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qidiruv natijalari',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        if (_searchLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Natija topilmadi',
              style: TextStyle(color: context.textSecondary),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              return BlocBuilder<FavoritesBloc, FavoritesState>(
                buildWhen: (prev, curr) =>
                    prev.isLiked(item.slug) != curr.isLiked(item.slug),
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
            },
          ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    if (_recommendationsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_recommendations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Tavsiyalar yo\'q',
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final item = _recommendations[index];
        return BlocBuilder<FavoritesBloc, FavoritesState>(
          buildWhen: (prev, curr) =>
              prev.isLiked(item.slug) != curr.isLiked(item.slug),
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
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final textColor = context.textPrimary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () => context.pop(),
                color: textColor,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    l10n.searchTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (q) {
          final t = q.trim();
          if (t.isNotEmpty) _runSearch(t);
        },
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SvgPicture.asset(
              'assets/svg/search.svg',
              width: 20,
              height: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequentChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _frequentSearches
          .map(
            (term) => ActionChip(
              avatar: Icon(
                Icons.search,
                size: 18,
                color: context.textSecondary,
              ),
              label: Text(term),
              backgroundColor: context.surfaceContainer,
              side: BorderSide.none,
              onPressed: () => _setSearchQuery(term),
            ),
          )
          .toList(),
    );
  }
}
