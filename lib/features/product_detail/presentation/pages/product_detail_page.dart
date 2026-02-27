import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/widgets/shimmer_placeholders.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

/// API dan kelgan sanani "26 Dek 2025" formatida qaytaradi (tilga qarab).
String? _formatAuthorDate(String? raw, String localeCode) {
  if (raw == null || raw.isEmpty) return null;
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  const uzMonths = [
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'Iyn',
    'Iyl',
    'Avg',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];
  const ruMonths = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  const enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final months = localeCode == 'uz'
      ? uzMonths
      : localeCode == 'ru'
      ? ruMonths
      : enMonths;
  final month = months[date.month - 1];
  return '${date.day} $month ${date.year}';
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final bgColor = context.bodyBackground;
    final cardColor = context.cardSurface;
    final iconColor = context.textPrimary;
    return BlocProvider(
      create: (_) {
        final bloc = getIt<ProductDetailBloc>();
        bloc.add(ProductDetailLoadRequested(slug));
        return bloc;
      },
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        buildWhen: (prev, curr) => prev.ad != curr.ad,
        builder: (context, detailState) {
          final ad = detailState.ad;
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: cardColor,
              surfaceTintColor: cardColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
                color: iconColor,
              ),
              actions: [
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  buildWhen: (prev, curr) =>
                      ad != null &&
                      prev.isLiked(ad.slug) != curr.isLiked(ad.slug),
                  builder: (context, likeState) {
                    final isLiked = ad != null &&
                        (likeState.isLiked(ad.slug) || ad.isLikes == true);
                    return IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: isLiked ? AppColors.red : iconColor,
                      onPressed: ad == null
                          ? null
                          : () {
                              context.read<FavoritesBloc>().add(
                                    FavoritesToggleRequested(
                                      adSlug: ad.slug,
                                      adForLocal: FavoriteItemEntity(
                                        slug: ad.slug,
                                        title: ad.title,
                                        mainImage: ad.mainImage,
                                        price: ad.price,
                                        finalPrice: ad.finalPrice,
                                        currency: ad.currency ?? 'uzs',
                                        rating: ad.rating ?? 0,
                                        reviewCount: ad.reviewCount ?? 0,
                                        isLiked: true,
                                      ),
                                    ),
                                  );
                            },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  color: iconColor,
                  onPressed: () {},
                ),
              ],
            ),
            body: _buildDetailBody(context, detailState),
          );
        },
      ),
    );
  }

  Widget _buildDetailBody(
    BuildContext context,
    ProductDetailState detailState,
  ) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state.status == ProductDetailStatus.loading) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerDetailImage(height: 300),
                    SizedBox(height: 12),
                    ShimmerDetailBlock(height: 100),
                    SizedBox(height: 16),
                    ShimmerDetailBlock(height: 60),
                    SizedBox(height: 16),
                    ShimmerDetailBlock(height: 80),
                    SizedBox(height: 16),
                    ShimmerDetailBlock(height: 120),
                    SizedBox(height: 32),
                  ],
                ),
              );
            }
            if (state.status == ProductDetailStatus.failure) {
              final l10n = AppLocalizations.of(context)!;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.error ?? l10n.productDetailErrorDefault,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.red),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.read<ProductDetailBloc>().add(
                          ProductDetailLoadRequested(slug),
                        ),
                        child: Text(l10n.actionRetry),
                      ),
                    ],
                  ),
                ),
              );
            }
            final ad = state.ad;
            if (ad == null) return const SizedBox.shrink();
            return _ProductDetailBody(ad: ad);
          },
        );
  }
}

class _ProductDetailBody extends StatefulWidget {
  const _ProductDetailBody({required this.ad});

  final AdDetailEntity ad;

  @override
  State<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends State<_ProductDetailBody>
    with SingleTickerProviderStateMixin {
  late final PageController _imagePageController;
  late final TabController _tabController;
  int _currentImage = 0;
  int? _selectedColorId;
  int? _selectedSizeId;

  AdDetailEntity get ad => widget.ad;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _tabController = TabController(length: 2, vsync: this);
    if (ad.colors.isNotEmpty) _selectedColorId = ad.colors.first.id;
    if (ad.sizes.isNotEmpty) _selectedSizeId = ad.sizes.first.id;
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatPrice(String? value) {
    if (value == null || value.isEmpty) return '';
    final intPart = value.split('.').first;
    final buf = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      buf.write(intPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) buf.write(' ');
    }
    return buf.toString().split('').reversed.join();
  }

  Color _parseHexColor(String hex, BuildContext context) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length >= 6) {
        return Color(0xFF000000 | int.parse(h.substring(0, 6), radix: 16));
      }
    } catch (_) {}
    return context.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(),
          const SizedBox(height: 12),
          _buildTitleSection(),
          if (ad.colors.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildColorSection(),
          ],
          if (ad.sizes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSizeSection(),
          ],
          const SizedBox(height: 16),
          _buildPriceSection(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildSellerSection(),
          const SizedBox(height: 16),
          _buildTabSection(),
          if (ad.similar.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSimilarSection(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = ad.images;
    final cardColor = context.cardSurface;
    final mutedColor = context.textSecondary;
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: cardColor,
        child: Center(
          child: Icon(Icons.image_not_supported, size: 64, color: mutedColor),
        ),
      );
    }
    return Container(
      color: cardColor,
      child: Stack(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _imagePageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImage = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image, size: 48, color: mutedColor),
                ),
              ),
            ),
          ),
          if (images.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CircleArrow(
                  icon: Icons.chevron_left,
                  context: context,
                  onTap: _currentImage > 0
                      ? () => _imagePageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CircleArrow(
                  icon: Icons.chevron_right,
                  context: context,
                  onTap: _currentImage < images.length - 1
                      ? () => _imagePageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImage + 1}/${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    return Container(
      color: context.cardSurface,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (ad.rating != null) ...[
                Icon(Icons.star, size: 16, color: AppColors.textYellow500),
                const SizedBox(width: 3),
                Text(
                  ad.rating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(Icons.chat_bubble_outline, size: 14, color: textSecondary),
              const SizedBox(width: 3),
              Text(
                '${ad.reviewCount ?? 0} ${AppLocalizations.of(context)!.reviewsLabel}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: textSecondary),
              ),
              const Spacer(),
              if (ad.viewsCount != null) ...[
                Icon(Icons.visibility_outlined, size: 14, color: textSecondary),
                const SizedBox(width: 3),
                Text(
                  '${ad.viewsCount}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ad.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.3,
            ),
          ),
          if (ad.categoryName != null) ...[
            const SizedBox(height: 4),
            Text(
              ad.categoryName!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    final borderColor = context.borderColor;
    return Container(
      color: context.cardSurface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.productDetailColorLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: ad.colors.map((c) {
              final selected = c.id == _selectedColorId;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorId = c.id),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _parseHexColor(c.colorHex, context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : borderColor,
                      width: selected ? 3 : 1.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;
    final cardColor = context.cardSurface;
    return Container(
      color: cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.productDetailSizeLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ad.sizes.map((s) {
                final selected = s.id == _selectedSizeId;
                final available = s.isAvailable;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: available
                        ? () => setState(() => _selectedSizeId = s.id)
                        : null,
                    child: CustomPaint(
                      foregroundPainter: available
                          ? null
                          : _DashedBorderPainter(color: textSecondary),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected && available
                              ? AppColors.primary
                              : cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: available
                              ? Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : borderColor,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: !available
                                    ? textSecondary
                                    : selected
                                    ? AppColors.white
                                    : textColor,
                                decoration: available
                                    ? null
                                    : TextDecoration.lineThrough,
                                decorationColor: textSecondary,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final hasDiscount =
        ad.price != null && ad.finalPrice != null && ad.price != ad.finalPrice;
    final curr = (ad.currency ?? 'uzs') == 'uzs' ? 'so\'m' : ad.currency!;
    return Container(
      color: context.cardSurface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDiscount)
            Text(
              '${_formatPrice(ad.price)} $curr',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          Text(
            '${_formatPrice(ad.finalPrice ?? ad.price)} $curr',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: context.cardSurface,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(AppLocalizations.of(context)!.productDetailCall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.productDetailTelegram,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/ad/${ad.slug}/order', extra: ad),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.productDetailPlaceOrder,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerSection() {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final surfaceContainer = context.surfaceContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adAuthorTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ad.userAvatar != null && ad.userAvatar!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ad.userAvatar!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.person_outline,
                            size: 28,
                            color: textSecondary,
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 28,
                          color: textSecondary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.userName ?? '—',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      if (ad.userDateJoined != null &&
                          ad.userDateJoined!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final localeCode = Localizations.localeOf(
                                    context,
                                  ).languageCode;
                                  final formatted = _formatAuthorDate(
                                    ad.userDateJoined,
                                    localeCode,
                                  );
                                  if (formatted == null)
                                    return const SizedBox.shrink();
                                  return Text(
                                    l10n.adAuthorOnPlatformSince(formatted),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: textSecondary),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // TODO: muallifning boshqa e'lonlari sahifasiga o'tish
                },
                style: TextButton.styleFrom(
                  backgroundColor: surfaceContainer,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.adAuthorOtherAds,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: context.cardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: context.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: l10n.tabFullInfo),
              Tab(text: l10n.tabReviews),
            ],
          ),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index == 0) {
                return _buildDescriptionTab();
              }
              return _buildReviewsTab();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final cardColor = context.cardSurface;
    final surfaceContainer = context.surfaceContainer;
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad.description != null && ad.description!.trim().isNotEmpty) ...[
            Text(
              ad.description!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.5),
            ),
          ],
          if (ad.options.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.productDetailFeatures,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            ...ad.options.asMap().entries.map((entry) {
              final isEven = entry.key.isEven;
              final o = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                color: isEven ? surfaceContainer : cardColor,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        o.name,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: textSecondary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        o.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_outline,
                size: 32,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.reviewsEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reviewsEmptySubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: sharh yozish
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.reviewsWriteReview,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarSection() {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.productDetailSimilarProducts,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.seeAll,
                      style: TextStyle(color: textSecondary),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            itemCount: ad.similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = ad.similar[index];
              return _SimilarCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _CircleArrow extends StatelessWidget {
  const _CircleArrow({required this.icon, required this.context, this.onTap});

  final IconData icon;
  final BuildContext context;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = this.context.isDark;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.85);
    final shadowColor = isDark ? Colors.black26 : Colors.black12;
    final iconColor = onTap != null
        ? this.context.textPrimary
        : this.context.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({required this.item});

  final AdSimilarEntity item;

  String _formatPrice(String? value) {
    if (value == null || value.isEmpty) return '';
    final intPart = value.split('.').first;
    final buf = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      buf.write(intPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) buf.write(' ');
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final curr = (item.currency ?? 'uzs') == 'uzs' ? 'so\'m' : item.currency!;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final cardColor = context.cardSurface;
    final borderColor = context.borderColor;
    return GestureDetector(
      onTap: () => context.push('/ad/${item.slug}'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: item.mainImage != null && item.mainImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.mainImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: context.surfaceContainer,
                        child: Icon(Icons.image, color: textSecondary),
                      ),
                    )
                  : Container(
                      color: context.surfaceContainer,
                      child: Center(
                        child: Icon(Icons.image, color: textSecondary),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.rating != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.textYellow500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                          ),
                          if (item.reviewCount != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 12,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.reviewCount}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: textSecondary),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (item.finalPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatPrice(item.finalPrice)} $curr',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => context.push('/ad/${item.slug}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue600,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.view,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );

    final path = Path()..addRRect(rrect);
    const double dashWidth = 6;
    const double dashSpace = 4;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
