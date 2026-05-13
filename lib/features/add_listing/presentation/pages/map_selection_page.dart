import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:dio/dio.dart';
import 'package:uzxarid/core/constants/app_keys.dart';

class MapSelectionPage extends StatefulWidget {
  final Point? initialPoint;
  const MapSelectionPage({super.key, this.initialPoint});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late YandexMapController _mapController;
  late final ValueNotifier<Point> _centerPosition;
  final ValueNotifier<bool> _isMapReady = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _addressName = ValueNotifier<String?>(null);
  int _searchSessionId = 0;

  @override
  void initState() {
    super.initState();
    _centerPosition = ValueNotifier<Point>(
      widget.initialPoint ?? const Point(latitude: 41.311081, longitude: 69.240562),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isMapReady.value = true;
        _searchAddress(_centerPosition.value);
      }
    });
  }

  @override
  void dispose() {
    _centerPosition.dispose();
    _isMapReady.dispose();
    _addressName.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

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

  Future<void> _zoomIn() async {
    if (!_isMapReady.value) return;
    await _mapController.moveCamera(
      CameraUpdate.zoomIn(),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.3,
      ),
    );
  }

  Future<void> _zoomOut() async {
    if (!_isMapReady.value) return;
    await _mapController.moveCamera(
      CameraUpdate.zoomOut(),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.3,
      ),
    );
  }

  Future<void> _searchAddress(Point point) async {
    final sessionId = ++_searchSessionId;
    try {
      final dio = Dio();
      final url = 'https://geocode-maps.yandex.ru/1.x/?apikey=${AppKeys.yandexGeocoderKey}&geocode=${point.longitude},${point.latitude}&format=json&lang=uz_UZ&results=1&kind=house';
      
      final response = await dio.get(url);
      if (sessionId != _searchSessionId) return;

      if (response.statusCode == 200) {
        final data = response.data;
        final featureMember = data['response']['GeoObjectCollection']['featureMember'] as List;
        if (featureMember.isNotEmpty) {
          final address = featureMember[0]['GeoObject']['metaDataProperty']['GeocoderMetaData']['text'];
          _addressName.value = address;
        } else {
          _addressName.value = null;
        }
      } else {
        _addressName.value = null;
      }
    } catch (e) {
      if (sessionId == _searchSessionId) {
        _addressName.value = null;
      }
      debugPrint("Search error: $e");
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
                      onCameraPositionChanged: (cameraPosition, reason, finished) {
                        if (finished && mounted) {
                          _centerPosition.value = cameraPosition.target;
                          _searchAddress(cameraPosition.target);
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
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _addressName,
                      builder: (context, address, child) {
                        return AppText(
                          text: address ?? 'Tanlangan joy',
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: 500,
                          textAlign: TextAlign.center,
                        );
                      },
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
                          color: textColor.withOpacity(0.2),
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
          // Zoom +/- controls
          Positioned(
            right: 16,
            bottom: 220,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: textColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _zoomIn,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.add, color: textColor, size: 22),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 1,
                    color: textColor.withValues(alpha: 0.12),
                  ),
                  InkWell(
                    onTap: _zoomOut,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.remove, color: textColor, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Controls
          Positioned(
            bottom: 150,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppImage(
                      path: AppAssets.backDropleft,
                      color: textColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppImage(path: AppAssets.location, color: textColor),
                  ),
                ),
              ],
            ),
          ),
          // Save Button
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  Navigator.pop(context, {
                    'point': _centerPosition.value,
                    'address': _addressName.value,
                  });
                },
                color: primaryColor,
                width: double.infinity,
                radius: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: AppText(
                      text: 'Tanlash',
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
