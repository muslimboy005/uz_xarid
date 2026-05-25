import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uzxarid/core/widgets/map_type_selector.dart';

class AppMap extends StatelessWidget {
  const AppMap({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.mapType,
    this.initialZoom = 14,
    this.minZoom = 3,
    this.maxZoom = 19,
    this.onPositionChanged,
    this.onMapReady,
    this.markerLayer,
    this.children,
  });

  final MapController mapController;
  final LatLng initialCenter;
  final AppMapType mapType;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;
  final VoidCallback? onMapReady;
  final Widget? markerLayer;
  final List<Widget>? children;

  static const String _userAgent = 'com.uzxarid.app';

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        onPositionChanged: onPositionChanged,
        onMapReady: onMapReady,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        ..._tileLayersFor(mapType),
        ?markerLayer,
        ...?children,
      ],
    );
  }

  static List<Widget> _tileLayersFor(AppMapType type) {
    switch (type) {
      case AppMapType.scheme:
        return [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: _userAgent,
            maxNativeZoom: 19,
          ),
        ];
      case AppMapType.satellite:
        return [
          TileLayer(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: _userAgent,
            maxNativeZoom: 19,
          ),
        ];
      case AppMapType.hybrid:
        return [
          TileLayer(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: _userAgent,
            maxNativeZoom: 19,
          ),
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: _userAgent,
            maxNativeZoom: 19,
            tileBuilder: (context, tileWidget, tile) {
              return ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  -2, 0, 0, 0, 510,
                  0, -2, 0, 0, 510,
                  0, 0, -2, 0, 510,
                  0, 0, 0, 1.6, 0,
                ]),
                child: tileWidget,
              );
            },
          ),
        ];
    }
  }
}
