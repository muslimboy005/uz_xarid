import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/shimmer_placeholders.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/product_detail/domain/entities/ad_detail_entity.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_feedback_bloc.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_feedback_event.dart';
import 'package:uz_xarid/features/product_detail/presentation/bloc/product_feedback_state.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/name_bottom_sheet.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/otp_bottom_sheet.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/phone_bottom_sheet.dart';
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
    // final surfaceContainer = context.surfaceContainer;
    final iconColor = context.textPrimary;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = getIt<ProductDetailBloc>();
            bloc.add(ProductDetailLoadRequested(slug));
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = getIt<ProductFeedbackBloc>();
            bloc.add(ProductFeedbackLoadRequested(slug: slug));
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) =>
              getIt<ProfileBloc>(), // local injection for bottom sheets
        ),
      ],
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
              leadingWidth: 64,
              leading: Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: AppImage(
                    path: AppAssets.backDropleft,
                    color: iconColor,
                  ),
                ),
              ),
              actions: [
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  buildWhen: (prev, curr) =>
                      ad != null &&
                      prev.isLiked(ad.slug) != curr.isLiked(ad.slug),
                  builder: (context, likeState) {
                    final isLiked =
                        ad != null &&
                        (likeState.isLiked(ad.slug) || ad.isLikes == true);
                    return GestureDetector(
                      onTap: ad == null
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
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite,
                          color: isLiked
                              ? AppColors.red
                              : context.textSecondary,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final state = context.read<ProductDetailBloc>().state;
                    if (state.status == ProductDetailStatus.success &&
                        state.ad != null) {
                      final slug = state.ad!.slug;
                      Share.shareUri(Uri.parse('https://uzxarid.uz/ad/$slug'));
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.ios_share,
                      size: 20,
                      color: context.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
  late final ValueNotifier<int> _currentImage;
  late final ValueNotifier<int?> _selectedColorId;
  late final ValueNotifier<int?> _selectedSizeId;
  final ValueNotifier<bool> _isDescExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFeaturesExpanded = ValueNotifier<bool>(false);

  AdDetailEntity get ad => widget.ad;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _tabController = TabController(length: 2, vsync: this);
    _currentImage = ValueNotifier<int>(0);
    _selectedColorId = ValueNotifier<int?>(
      ad.colors.isNotEmpty ? ad.colors.first.id : null,
    );
    _selectedSizeId = ValueNotifier<int?>(
      ad.sizes.isNotEmpty ? ad.sizes.first.id : null,
    );
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    _currentImage.dispose();
    _selectedColorId.dispose();
    _selectedSizeId.dispose();
    _isDescExpanded.dispose();
    _isFeaturesExpanded.dispose();
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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

    return Column(
      children: [
        // Main Image Card
        AspectRatio(
          aspectRatio: 1.0,
          child: ContainerW(
            color: cardColor,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: _imagePageController,
                    itemCount: images.length,
                    onPageChanged: (i) => _currentImage.value = i,
                    itemBuilder: (_, i) => AppImage(
                      path: images[i],
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      // placeholder: (_, __) => const Center(
                      //   child: CircularProgressIndicator(strokeWidth: 2),
                      // ),
                      errorWidget: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Video button
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: AppColors.white,
                      size: 20,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.productDetailWatchVideo,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Thumbnails list
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 64, // Thumbnail height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _currentImage == index;
                return GestureDetector(
                  onTap: () {
                    _imagePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : context.borderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleSection() {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (ad.rating != null) ...[
              Icon(Icons.star, size: 16, color: AppColors.orange),
              const SizedBox(width: 4),
              Text(
                ad.rating!.toStringAsFixed(2), // 4.92 format
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 16),
            ],
            const Icon(Icons.chat, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '${ad.reviewCount ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          ad.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.productDetailInStock(''),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textSecondary),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.productDetailColorLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int?>(
          valueListenable: _selectedColorId,
          builder: (context, selectedId, _) {
            return Wrap(
              spacing: 12,
              runSpacing: 8,
              children: ad.colors.map((c) {
                final selected = c.id == selectedId;
                final color = _parseHexColor(c.colorHex, context);
                return GestureDetector(
                  onTap: () => _selectedColorId.value = c.id,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? color.withOpacity(0.8)
                            : context.borderColor,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: selected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSizeSection() {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;
    final cardColor = context.cardSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.productDetailSizeLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int?>(
          valueListenable: _selectedSizeId,
          builder: (context, selectedId, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ad.sizes.map((s) {
                  final selected = s.id == selectedId;
                  final available = s.isAvailable;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: available
                          ? () => _selectedSizeId.value = s.id
                          : null,
                      child: CustomPaint(
                        foregroundPainter: available
                            ? null
                            : _DashedBorderPainter(color: textSecondary),
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 70),
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
                                        : borderColor.withOpacity(0.5),
                                    width: 1,
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: !available
                                      ? textSecondary
                                      : selected
                                      ? AppColors.white
                                      : textColor,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final hasDiscount =
        ad.price != null && ad.finalPrice != null && ad.price != ad.finalPrice;
    final curr = (ad.currency ?? 'uzs') == 'uzs' ? 'сум' : ad.currency!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDiscount)
          Text(
            '${_formatPrice(ad.price)} $curr',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          '${_formatPrice(ad.finalPrice ?? ad.price)} $curr',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ContainerW(
                onTap: () {},
                radius: 12,
                color: context.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppImage(
                        path: AppAssets.call,
                        color: context.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AppText(
                          text: AppLocalizations.of(context)!.productDetailCall,
                          fontWeight: 500,
                          fontSize: 16,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ContainerW(
                onTap: () {},
                color: context.surfaceContainer,
                radius: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppImage(
                        path: AppAssets.telegram,
                        color: context.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AppText(
                          text: AppLocalizations.of(
                            context,
                          )!.productDetailTelegram,
                          fontWeight: 500,
                          fontSize: 16,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        ContainerW(
          width: double.infinity,
          onTap: () => context.push('/ad/${ad.slug}/order', extra: ad),
          color: AppColors.blue500,
          radius: 12,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: AppText(
                text: AppLocalizations.of(context)!.productDetailPlaceOrder,
                fontWeight: 500,
                fontSize: 16,
                color: context.textWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerSection() {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final surfaceContainer = context.surfaceContainer;
    return ContainerW(
      color: context.cardSurface,
      radius: 12,
      borderColor: context.borderColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.adAuthorTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                // Text(
                //   "Kecha 12:35 da bo'lgan",
                //   style: Theme.of(
                //     context,
                //   ).textTheme.bodySmall?.copyWith(color: textSecondary),
                // ),
              ],
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
                                  if (formatted == null) {
                                    return const SizedBox.shrink();
                                  }
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
            ContainerW(
              onTap: () {
                if (ad.userId != null) {
                  context.push('/author/${ad.userId}');
                }
              },
              width: double.infinity,
              color: AppColors.blue500,
              radius: 12,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Center(
                  child: AppText(
                    text: l10n.adAuthorOtherAds,
                    fontWeight: 500,
                    fontSize: 16,
                    color: context.textWhite,
                  ),
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
    return ContainerW(
      color: context.cardSurface,
      borderColor: context.borderColor,
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
              vertical: 8,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.white,
                unselectedLabelColor: context.textPrimary,
                indicator: BoxDecoration(
                  color: AppColors.blue500,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                labelStyle: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: l10n.tabFullInfo),
                  Tab(text: l10n.tabReviews),
                ],
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad.description != null && ad.description!.trim().isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.productDetailDescription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: _isDescExpanded,
              builder: (context, isDescExpanded, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.description!,
                      maxLines: isDescExpanded ? null : 6,
                      overflow: isDescExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () =>
                          _isDescExpanded.value = !_isDescExpanded.value,
                      child: Row(
                        children: [
                          Text(
                            isDescExpanded
                                ? AppLocalizations.of(
                                    context,
                                  )!.productDetailHide
                                : AppLocalizations.of(
                                    context,
                                  )!.productDetailShowAll,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isDescExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (ad.options.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.productDetailFeatures,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _isFeaturesExpanded,
              builder: (context, isFeaturesExpanded, _) {
                return Column(
                  children: [
                    ...ad.options
                        .take(isFeaturesExpanded ? ad.options.length : 5)
                        .map((o) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        o.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: textSecondary),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        o.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: context.borderColor),
                              ],
                            ),
                          );
                        }),
                    if (ad.options.length > 5) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _isFeaturesExpanded.value =
                            !_isFeaturesExpanded.value,
                        child: Row(
                          children: [
                            Text(
                              isFeaturesExpanded
                                  ? AppLocalizations.of(
                                      context,
                                    )!.productDetailHide
                                  : AppLocalizations.of(
                                      context,
                                    )!.productDetailShowAll,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isFeaturesExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final l10n = AppLocalizations.of(context)!;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return BlocBuilder<ProductFeedbackBloc, ProductFeedbackState>(
      builder: (context, state) {
        if (state.status == ProductFeedbackStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final dynamic rawResponse = state.feedbacks;
        final dynamic data = rawResponse?['data'] ?? rawResponse;
        final List<dynamic> results = (data != null && data['results'] != null)
            ? List<dynamic>.from(data['results'])
            : [];

        if (results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_outline,
                      size: 28,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.reviewsEmptyTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.reviewsEmptySubtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLeaveFeedbackSheet(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Написать отзыв',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Отзывы (${results.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showLeaveFeedbackSheet(context),
                    child: Text(
                      l10n.reviewsWriteReview,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...results.map((r) {
                final author = r['user'] ?? {};
                final name =
                    '${author['first_name'] ?? ''} ${author['last_name'] ?? ''}'
                        .trim();
                final finalName = name.isEmpty
                    ? (author['username'] ?? 'Foydalanuvchi')
                    : name;
                final text = r['comment'] ?? '';
                final rating = r['rating'] is num
                    ? (r['rating'] as num).toInt()
                    : 0;
                final createdAt = r['created_at'] != null
                    ? _formatAuthorDate(
                        r['created_at'],
                        Localizations.localeOf(context).languageCode,
                      )
                    : '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: context.surfaceContainer,
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  finalName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                if (rating > 0)
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 14,
                                        color: AppColors.orange,
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          ),
                          if (createdAt != null)
                            Text(
                              createdAt,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: textSecondary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLeaveFeedbackSheet(BuildContext parentContext) async {
    // Check if user is authenticated via local storage
    if (!parentContext.mounted) return;
    final hasToken = await getIt<SecureStorageService>().hasToken();
    if (!parentContext.mounted) return;

    if (!hasToken) {
      // User is not authenticated, show login flow
      PhoneBottomSheet.show(
        parentContext,
        onCodeSent: (phone) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (parentContext.mounted) {
              OtpBottomSheet.show(
                parentContext,
                phone,
                onAskName: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (parentContext.mounted) {
                      NameBottomSheet.show(parentContext);
                    }
                  });
                },
                onOtpSuccess: () {
                  if (parentContext.mounted) {
                    parentContext.read<ProfileBloc>().add(
                      const ProfileLoadEvent(),
                    );
                    parentContext.read<ProductFeedbackBloc>().add(
                      ProductFeedbackLoadRequested(slug: ad.slug),
                    );
                  }
                },
              );
            }
          });
        },
      );
      return;
    }

    final l10n = AppLocalizations.of(parentContext)!;
    final controller = TextEditingController();
    int rating = 0;
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: parentContext.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: AppDimens.paddingMedium,
                right: AppDimens.paddingMedium,
                top: AppDimens.paddingMedium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.reviewsWriteReview,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: AppColors.orange,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Fikr qoldiring...',
                      hintStyle: TextStyle(color: parentContext.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: parentContext.borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: parentContext.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocConsumer<ProductFeedbackBloc, ProductFeedbackState>(
                      bloc: parentContext
                          .read<
                            ProductFeedbackBloc
                          >(), // use the bloc from parent context
                      listenWhen: (prev, curr) => prev.status != curr.status,
                      listener: (context, state) {
                        if (state.status ==
                            ProductFeedbackStatus.submitSuccess) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sharh yuborildi'),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        } else if (state.status ==
                            ProductFeedbackStatus.submitFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error ?? 'Xatolik'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isSubmitting =
                            state.status == ProductFeedbackStatus.submitting;
                        return ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  if (controller.text.trim().isEmpty ||
                                      rating == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Iltimos, baho bering va fikringizni yozing',
                                        ),
                                        backgroundColor: AppColors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  parentContext.read<ProductFeedbackBloc>().add(
                                    ProductFeedbackLeaveRequested(
                                      slug: ad.slug,
                                      data: {
                                        "comment": controller.text.trim(),
                                        "rating": rating,
                                      },
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Yuborish',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSimilarSection() {
    final l10n = AppLocalizations.of(context)!;
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
                onPressed: () => context.push(
                  '/products?title=${Uri.encodeComponent(l10n.recommendationsTitle)}',
                ),
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
    final curr = (item.currency ?? 'uzs') == 'uzs' ? 'сум' : item.currency!;
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppImage(
                      path: item.mainImage ?? '',
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: context.surfaceContainer,
                        child: Center(
                          child: Icon(Icons.image, color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoritesBloc, FavoritesState>(
                      buildWhen: (prev, curr) =>
                          prev.isLiked(item.slug) != curr.isLiked(item.slug),
                      builder: (context, likeState) {
                        final isLiked = likeState.isLiked(item.slug);
                        return GestureDetector(
                          onTap: () {
                            context.read<FavoritesBloc>().add(
                              FavoritesToggleRequested(
                                adSlug: item.slug,
                                adForLocal: FavoriteItemEntity(
                                  slug: item.slug,
                                  title: item.title,
                                  mainImage: item.mainImage,
                                  price: item
                                      .finalPrice, // Assuming similar doesn't map price, just finalPrice
                                  finalPrice: item.finalPrice,
                                  currency: item.currency ?? 'uzs',
                                  rating: item.rating ?? 0,
                                  reviewCount: item.reviewCount ?? 0,
                                  isLiked: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: context.surfaceContainer.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? AppColors.red : textSecondary,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.rating != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                          ),
                          if (item.reviewCount != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.productDetailReviewsCount(
                                '${item.reviewCount}',
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: textSecondary),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    if (item.price != null &&
                        item.price != item.finalPrice) ...[
                      Text(
                        '${_formatPrice(item.price)} $curr',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    if (item.finalPrice != null)
                      Text(
                        '${_formatPrice(item.finalPrice)} $curr',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
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
