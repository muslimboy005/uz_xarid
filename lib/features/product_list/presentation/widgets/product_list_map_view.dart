import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_map.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/glass_container.dart';
import 'package:uzxarid/core/widgets/map_type_selector.dart';
import 'package:uzxarid/features/currency/domain/currency.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uzxarid/features/product_list/domain/entities/product_list_item_entity.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

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

  static const LatLng kMapCenter = LatLng(41.32178969, 69.24735733);

  static const double kInitialZoom = 14;

  @override
  State<ProductListMapView> createState() => _ProductListMapViewState();
}

class _ProductListMapViewState extends State<ProductListMapView> {
  bool _mapReady = false;
  final MapController _mapController = MapController();
  AppMapType _mapType = AppMapType.scheme;

  void _zoomIn() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + 1).clamp(3, 19));
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom - 1).clamp(3, 19));
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _mapReady = true);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Koordinatasi (lat/long) bor e'lonlar — xaritada shu nuqtada ko'rsatiladi.
  List<ProductListItemEntity> get _locatedItems =>
      widget.items.where((e) => e.hasLocation).toList();

  List<LatLng> get _points => _locatedItems
      .map((e) => LatLng(e.latitude!, e.longitude!))
      .toList(growable: false);

  /// Boshlang'ich markaz: koordinatalar o'rtasi (yo'q bo'lsa — Toshkent markazi).
  LatLng get _initialCenter {
    final pts = _points;
    if (pts.isEmpty) return ProductListMapView.kMapCenter;
    var lat = 0.0;
    var lng = 0.0;
    for (final p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / pts.length, lng / pts.length);
  }

  /// Xarita tayyor bo'lgach, barcha pinlar ko'rinadigan qilib kamerani moslaydi.
  void _fitToMarkers() {
    final pts = _points;
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _mapController.move(pts.first, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: pts,
        padding: const EdgeInsets.all(64),
        maxZoom: 16,
      ),
    );
  }

  List<Marker> _markers(BuildContext context) {
    final located = _locatedItems;
    if (located.isEmpty) return [];
    const maxPins = 60;
    final pinColor = context.read<AppModeCubit>().state.primaryColor;
    final ccyLabel = currencyDisplayLabel(
      context.read<CurrencyCubit>().state.selectedCcy,
    );
    return located.take(maxPins).map((item) {
      final priceStr = formatPrice(item.finalPrice ?? item.price);
      final label = priceStr.isEmpty ? null : '$priceStr $ccyLabel';
      return Marker(
        point: LatLng(item.latitude!, item.longitude!),
        width: 160,
        height: 46,
        // Pin uchi (pastki qismi) aynan koordinata ustida tursin.
        alignment: Alignment.topCenter,
        child: _PriceMarker(
          label: label,
          color: pinColor,
          onTap: () {
            if (item.slug.isNotEmpty) context.push('/ad/${item.slug}');
          },
        ),
      );
    }).toList();
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
    final zoomReady = _mapReady;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: const Color(0xFFEEF2F6),
          child: _mapReady
              ? AppMap(
                  mapController: _mapController,
                  initialCenter: _initialCenter,
                  initialZoom: ProductListMapView.kInitialZoom,
                  mapType: _mapType,
                  onMapReady: _fitToMarkers,
                  markerLayer: MarkerLayer(markers: _markers(context)),
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
              child: GlassContainer(
                borderRadius: 14,
                child: Material(
                  color: Colors.transparent,
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
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 64,
          right: 16,
          child: MapTypeSelector(
            current: _mapType,
            onChanged: (t) => setState(() => _mapType = t),
          ),
        ),
      ],
    );
  }
}

/// Xaritadagi e'lon belgisi: narx «pill» ko'rinishida, ostida pastga ishora
/// qiluvchi uchi bilan (narx bo'lmasa — oddiy doira nuqta).
class _PriceMarker extends StatelessWidget {
  const _PriceMarker({required this.color, this.label, this.onTap});

  final Color color;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Pill ostidagi pastga qaragan uchi.
          Transform.translate(
            offset: const Offset(0, -3),
            child: Transform.rotate(
              angle: 0.7853981633974483, // 45°
              child: Container(width: 8, height: 8, color: color),
            ),
          ),
        ],
      ),
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
            const SizedBox(height: 8),
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
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
                                      const SizedBox(height: 6),
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
