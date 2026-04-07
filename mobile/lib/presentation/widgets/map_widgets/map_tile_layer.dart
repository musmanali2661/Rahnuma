import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';

/// The OSM tile layer for the map.
class MapTileLayer extends StatelessWidget {
  const MapTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: AppConstants.osmTileUrl,
      userAgentPackageName: 'app.rahnuma.mobile',
      maxNativeZoom: 19,
    );
  }
}

/// Displays the user's current location as a pulsing blue dot.
class LocationMarkerWidget extends StatelessWidget {
  const LocationMarkerWidget({
    super.key,
    required this.position,
    this.heading,
  });

  final LatLng position;
  final double? heading;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: position,
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withAlpha(51),
                  border: Border.all(
                    color: Colors.blue.withAlpha(102),
                    width: 1,
                  ),
                ),
              ),
              // Inner dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade700,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Heading arrow if available
              if (heading != null)
                Transform.rotate(
                  angle: (heading! * 3.14159265 / 180),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
