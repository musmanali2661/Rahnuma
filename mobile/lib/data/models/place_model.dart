/// A geographic coordinate (latitude / longitude).
class LatLon {
  const LatLon(this.lat, this.lon);

  final double lat;
  final double lon;

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};

  @override
  String toString() => '($lat, $lon)';
}

/// Represents a search result / saved place.
class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.nameUr,
    this.category,
    this.address,
    this.confidence,
  });

  final String id;
  final String name;
  final double lat;
  final double lon;
  final String? nameUr;
  final String? category;
  final String? address;
  final double? confidence;

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    // Handle both flat and GeoJSON-style responses from Nominatim
    double lat = 0;
    double lon = 0;
    if (json['geometry'] != null) {
      final coords = (json['geometry']['coordinates'] as List<dynamic>);
      lon = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    } else {
      lat = (json['lat'] as num?)?.toDouble() ?? 0;
      lon = (json['lon'] as num?)?.toDouble() ?? 0;
    }

    final props = json['properties'] as Map<String, dynamic>? ?? json;
    return PlaceModel(
      id: (props['place_id'] ?? props['id'] ?? '').toString(),
      name: props['name'] as String? ??
          props['display_name'] as String? ??
          'Unknown',
      nameUr: props['name_ur'] as String?,
      lat: lat,
      lon: lon,
      category: props['category'] as String?,
      address: props['display_name'] as String? ?? props['address'] as String?,
      confidence: (props['confidence'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() => name;
}
