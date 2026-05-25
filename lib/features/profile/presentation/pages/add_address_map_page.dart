import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:uzxarid/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_map.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/glass_container.dart';
import 'package:uzxarid/core/widgets/map_type_selector.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/profile/data/model/address_model.dart';

class AddAddressMapPage extends StatefulWidget {
  final AddressModel? address;
  const AddAddressMapPage({super.key, this.address});

  @override
  State<AddAddressMapPage> createState() => _AddAddressMapPageState();
}

class _AddAddressMapPageState extends State<AddAddressMapPage> {
  final MapController _mapController = MapController();
  late final ValueNotifier<LatLng> _centerPosition;

  final ValueNotifier<bool> _isMapReady = ValueNotifier<bool>(false);
  AppMapType _mapType = AppMapType.scheme;

  @override
  void initState() {
    super.initState();
    _centerPosition = ValueNotifier<LatLng>(
      widget.address != null
          ? LatLng(widget.address!.latitude, widget.address!.longitude)
          : const LatLng(41.311081, 69.240562),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isMapReady.value = true;
      }
    });
  }

  @override
  void dispose() {
    _centerPosition.dispose();
    _isMapReady.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joylashuv xizmatlari yoqilmagan.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Joylashuv ruxsati rad etildi.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joylashuv ruxsati butunlay rad etilgan.'),
          ),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_isMapReady.value) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          16.0,
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    return Scaffold(
      backgroundColor: context.bodyBackground,
      body: Stack(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isMapReady,
            builder: (context, isReady, child) {
              return isReady
                  ? AppMap(
                      mapController: _mapController,
                      initialCenter: _centerPosition.value,
                      initialZoom: 14,
                      mapType: _mapType,
                      onPositionChanged: (camera, hasGesture) {
                        if (mounted) {
                          _centerPosition.value = camera.center;
                        }
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
            },
          ),

          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 60,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppText(
                      text: AppLocalizations.of(context)!.addressAddMapSelectedSub,
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: 500,
                    ),
                  ),
                  Container(width: 2, height: 10, color: AppColors.white),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 2, height: 20, color: AppColors.white),
                ],
              ),
            ),
          ),

          // Map type selector (Sxema / Sputnik / Gibrid)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: MapTypeSelector(
              current: _mapType,
              onChanged: (t) => setState(() => _mapType = t),
            ),
          ),

          // Controls at the bottom (Back and GPS)
          Positioned(
            bottom: 150,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassContainer(
                  borderRadius: 14,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: AppImage(
                          path: AppAssets.backDropleft,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
                GlassContainer(
                  borderRadius: 14,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _getCurrentLocation,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: AppImage(
                          path: AppAssets.location,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Save Button Container at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassContainer(
              borderRadiusGeometry: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: ContainerW(
                onTap: () async {
                  final latLng = _centerPosition.value;
                  if (widget.address != null) {
                    final updatedAddress = AddressModel(
                      id: widget.address!.id,
                      name: widget.address!.name,
                      address: widget.address!.address,
                      apartment: widget.address!.apartment,
                      entrance: widget.address!.entrance,
                      floor: widget.address!.floor,
                      comment: widget.address!.comment,
                      longitude: _centerPosition.value.longitude,
                      latitude: _centerPosition.value.latitude,
                    );
                    final result = await context.pushNamed(
                      'profile-add-address-form',
                      extra: updatedAddress,
                    );
                    if (result == true && context.mounted) {
                      context.pop(true);
                    }
                  } else {
                    final result = await context.pushNamed(
                      'profile-add-address-form',
                      extra: latLng,
                    );
                    if (result == true && context.mounted) {
                      context.pop(true);
                    }
                  }
                },
                color: primaryColor,
                width: double.infinity,
                radius: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: AppText(
                      text: AppLocalizations.of(context)!.addressSave,
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: 600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
