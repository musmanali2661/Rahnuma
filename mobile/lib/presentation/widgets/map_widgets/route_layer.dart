import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/route_model.dart';

/// Renders the active route polyline on the map.
class RouteLayer extends StatelessWidget {
  const RouteLayer({
    super.key,
    required this.route,
  });

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    final points = _decodeGeometry(route.geometry);
    if (points.isEmpty) return const SizedBox.shrink();

    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          strokeWidth: 6.0,
          color: AppColors.infoBlue,
        ),
        // Thin border for contrast
        Polyline(
          points: points,
          strokeWidth: 8.0,
          color: AppColors.infoBlue.withAlpha(77),
        ),
      ],
    );
  }

  /// Decode route geometry.
  ///
  /// The backend may return an encoded polyline string or a GeoJSON geometry
  /// object. This handles both cases for Phase 1.
  List<LatLng> _decodeGeometry(dynamic geometry) {
    if (geometry == null) return [];

    // GeoJSON LineString
    if (geometry is Map<String, dynamic> &&
        geometry['type'] == 'LineString') {
      final coords = geometry['coordinates'] as List<dynamic>;
      return coords
          .map((c) {
            final coord = c as List<dynamic>;
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          })
          .toList();
    }

    // Encoded polyline string (Google polyline encoding)
    if (geometry is String) {
      return _decodePolyline(geometry);
    }

    return [];
  }

  /// Decode a Google-encoded polyline string into a list of [LatLng].
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
