import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:latlong2/latlong.dart' as lt;
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

class AddAddressMapPage extends StatefulWidget {
  const AddAddressMapPage({super.key});

  @override
  State<AddAddressMapPage> createState() => _AddAddressMapPageState();
}

class _AddAddressMapPageState extends State<AddAddressMapPage> {
  late YandexMapController _mapController;
  final ValueNotifier<Point> _centerPosition = ValueNotifier<Point>(
    const Point(latitude: 41.311081, longitude: 69.240562),
  );

  final ValueNotifier<bool> _isMapReady = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // Delay initialization to prevent page transition jank
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
        _mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
              zoom: 16.0,
            ),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 1.0,
          ),
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bodyBackground,
      body: Stack(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isMapReady,
            builder: (context, isReady, child) {
              return isReady
                  ? YandexMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _mapController.moveCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _centerPosition.value,
                              zoom: 14.0,
                            ),
                          ),
                        );
                      },
                      onCameraPositionChanged:
                          (cameraPosition, reason, finished) {
                            if (finished && mounted) {
                              _centerPosition.value = cameraPosition.target;
                            }
                          },
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
            },
          ),

          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 60,
              ), // Adjust for the pin's stalk
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppText(
                      text: 'Tanlangan manzil',
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
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black500.withOpacity(0.2),
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
                          color: AppColors.primary,
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

          // Controls at the bottom (Back and GPS)
          Positioned(
            bottom: 100, // Above the save button panel
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black500.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: AppColors.black500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black500.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.near_me_outlined,
                      size: 24,
                      color: AppColors.black500,
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
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: context.cardSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ContainerW(
                onTap: () {
                  context.push(
                    '/profile/add-address-form',
                    extra: lt.LatLng(
                      _centerPosition.value.latitude,
                      _centerPosition.value.longitude,
                    ),
                  );
                },
                color: AppColors.primary,
                width: double.infinity,
                radius: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: AppText(
                      text: 'Сохранить',
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
