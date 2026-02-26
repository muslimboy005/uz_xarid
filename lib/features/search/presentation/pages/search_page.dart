import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

/// To'liq qidirish ekrani: kategoriyalar, tez-tez qidiriladi, tavsiyalar.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static const List<String> _frequentSearches = ['iphone', 'komu'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldBg = context.bodyBackground;
    final textColor = context.textPrimary;
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: _buildSearchField(context, l10n),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.searchFindByCategory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryChips(context, l10n),
                    const SizedBox(height: 24),
                    Text(
                      l10n.searchFrequentlySearched,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFrequentChips(context),
                    const SizedBox(height: 24),
                    Text(
                      l10n.recommendationsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          '',
                          style: TextStyle(color: context.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildCategoryChips(BuildContext context, AppLocalizations l10n) {
    final categories = [
      l10n.categoryAutoMoto,
      l10n.categoryConstruction,
      'Category 1',
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(categories[index]),
            backgroundColor: context.surfaceContainer,
            side: BorderSide.none,
            onPressed: () {},
          );
        },
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
              onPressed: () {},
            ),
          )
          .toList(),
    );
  }
}
