import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/network/yandex_map_coverage.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/utils/price_formatter.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/features/currency/domain/currency.dart';
import 'package:uz_xarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uz_xarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uz_xarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Mahsulotlar ro‘yxati — xarita rejimi (Yandex) va «Ro‘yxat» bottom sheet.
class ProductListMapView extends StatefulWidget {
  const ProductListMapView({
    super.key,
    required this.title,
    required this.items,
    required this.onBack,
    required this.onOpenFilters,
    required this.filterActive,
  });

  final String title;
  final List<ProductListItemEntity> items;
  final VoidCallback onBack;
  final VoidCallback onOpenFilters;
  final bool filterActive;

  static const Point kMapCenter = Point(
    latitude: 41.32178969,
    longitude: 69.24735733,
  );

  static const double kInitialZoom = 14;

  @override
  State<ProductListMapView> createState() => _ProductListMapViewState();
}

class _ProductListMapViewState extends State<ProductListMapView> {
  bool _mapReady = false;
  YandexMapController? _mapController;

  static const MapAnimation _zoomAnim = MapAnimation(
    type: MapAnimationType.smooth,
    duration: 0.22,
  );

  void _zoomIn() {
    _mapController?.moveCamera(
      CameraUpdate.zoomIn(),
      animation: _zoomAnim,
    );
  }

  void _zoomOut() {
    _mapController?.moveCamera(
      CameraUpdate.zoomOut(),
      animation: _zoomAnim,
    );
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _mapReady = true);
    });
    fetchYandexMapCoverageSuccess(
      longitude: ProductListMapView.kMapCenter.longitude,
      latitude: ProductListMapView.kMapCenter.latitude,
      zoom: ProductListMapView.kInitialZoom.round(),
    );
  }

  List<MapObject> _mapObjects(BuildContext context) {
    final center = ProductListMapView.kMapCenter;
    if (widget.items.isEmpty) return [];
    const maxPins = 48;
    final pinColor = context.read<AppModeCubit>().state.primaryColor;
    return widget.items.take(maxPins).toList().asMap().entries.map((e) {
      final idx = e.key;
      final item = e.value;
      final p = _scatterPoint(center, item.slug, idx);
      return CircleMapObject(
        mapId: MapObjectId('pin_$idx'),
        circle: Circle(center: p, radius: 42),
        fillColor: pinColor,
        strokeColor: Colors.white,
        strokeWidth: 2,
        consumeTapEvents: true,
        onTap: (CircleMapObject circle, Point point) {
          if (item.slug.isNotEmpty) context.push('/ad/${item.slug}');
        },
      );
    }).toList();
  }

  /// API koordinatasi bo‘lmaganda — markaz atrofida tarqatilgan ko‘k nuqtalar.
  static Point _scatterPoint(Point center, String slug, int index) {
    final h = slug.hashCode ^ (17 * index);
    final a = (h % 360) * math.pi / 180;
    final r = 0.001 + (h.abs() % 7) * 0.00022;
    return Point(
      latitude: center.latitude + r * math.sin(a),
      longitude: center.longitude + r * math.cos(a),
    );
  }

  void _openListingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ListingsBottomSheet(items: widget.items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textPrimary;
    final border = context.borderColor;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final count = widget.items.length;
    final zoomReady = _mapController != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: const Color(0xFFEEF2F6),
          child: _mapReady
              ? YandexMap(
                  mapObjects: _mapObjects(context),
                  mode2DEnabled: true,
                  onMapCreated: (YandexMapController c) {
                    _mapController = c;
                    c.moveCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: ProductListMapView.kMapCenter,
                          zoom: ProductListMapView.kInitialZoom,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                )
              : Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: textPrimary,
                      onPressed: widget.onBack,
                    ),
                    Expanded(
                      child: Text(
                        '${widget.title} ($count)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onOpenFilters,
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.tune_rounded, size: 20, color: textPrimary),
                          if (widget.filterActive)
                            Positioned(
                              right: -2,
                              top: -2,
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
                      label: Text(
                        'Filtrlar',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Material(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _openListingsSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.list_rounded, color: textPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'Ro\'yxat',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: SafeArea(
            child: Center(
              child: Material(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: zoomReady ? _zoomIn : null,
                      icon: Icon(Icons.add, size: 22, color: textPrimary),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: border),
                    IconButton(
                      onPressed: zoomReady ? _zoomOut : null,
                      icon: Icon(Icons.remove, size: 22, color: textPrimary),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListingsBottomSheet extends StatelessWidget {
  const _ListingsBottomSheet({required this.items});
  final List<ProductListItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final border = context.borderColor;
    final appMode = context.watch<AppModeCubit>().state;
    final badgeLabel = appMode == AppMode.buying
        ? l10n.adTypeBuy
        : l10n.supportMenuSotaman;
    final primaryColor = appMode.primaryColor;
    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final selectedCurrencyLabel = currencyDisplayLabel(selectedCcy);

    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.22,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: border)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'E\'lonlar ro\'yxati',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: textPrimary),
                  ),
                ],
              ),
            ),
            Divider(color: border, height: 1),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.productsNotFoundTitle,
                        style: TextStyle(color: textSecondary),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(color: border),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final priceStr = formatPrice(
                          item.finalPrice ?? item.price,
                        );
                        final currency = selectedCurrencyLabel;

                        return InkWell(
                          onTap: () {
                            if (item.slug.isNotEmpty) {
                              context.push('/ad/${item.slug}');
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 76,
                                    height: 76,
                                    child: AppImage(
                                      path: item.mainImage ?? '',
                                      fit: BoxFit.cover,
                                      errorWidget: ColoredBox(
                                        color: border.withValues(alpha: 0.3),
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          AppImage(
                                            path: AppAssets.star,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.rating.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          AppImage(
                                            path: AppAssets.chat,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${item.reviewCount} ${l10n.reviewsLabel}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              badgeLabel,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AppText(
                                        text: priceStr.isEmpty
                                            ? ''
                                            : '$priceStr $currency',
                                        fontSize: 16,
                                        fontWeight: 700,
                                        color: primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                                BlocBuilder<FavoritesBloc, FavoritesState>(
                                  buildWhen: (p, c) =>
                                      p.isLiked(item.slug) !=
                                      c.isLiked(item.slug),
                                  builder: (context, s) => IconButton(
                                    onPressed: () => context
                                        .read<FavoritesBloc>()
                                        .add(
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
                                    icon: AppImage(
                                      path: AppAssets.heartOutline,
                                      color: s.isLiked(item.slug)
                                          ? AppColors.red
                                          : AppColors.black200,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
