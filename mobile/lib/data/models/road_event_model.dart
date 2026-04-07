/// Types of road events collected from IMU sensors.
enum RoadEventType {
  pothole,
  speedBump,
  roughRoad,
}

extension RoadEventTypeExt on RoadEventType {
  String get apiValue => switch (this) {
        RoadEventType.pothole => 'pothole',
        RoadEventType.speedBump => 'speed_bump',
        RoadEventType.roughRoad => 'rough_road',
      };

  static RoadEventType fromString(String value) => switch (value) {
        'speed_bump' => RoadEventType.speedBump,
        'rough_road' => RoadEventType.roughRoad,
        _ => RoadEventType.pothole,
      };
}

/// A single IMU-detected road surface event.
class RoadEventModel {
  const RoadEventModel({
    required this.lat,
    required this.lon,
    required this.eventType,
    required this.confidence,
    this.id,
    this.createdAt,
    this.verified = false,
  });

  final double lat;
  final double lon;
  final RoadEventType eventType;
  final double confidence;
  final String? id;
  final DateTime? createdAt;
  final bool verified;

  factory RoadEventModel.fromJson(Map<String, dynamic> json) {
    double lat = 0;
    double lon = 0;
    if (json['geojson'] != null) {
      final coords = json['geojson']['coordinates'] as List<dynamic>;
      lon = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    } else {
      lat = (json['lat'] as num?)?.toDouble() ?? 0;
      lon = (json['lon'] as num?)?.toDouble() ?? 0;
    }

    return RoadEventModel(
      id: json['id'] as String?,
      lat: lat,
      lon: lon,
      eventType: RoadEventTypeExt.fromString(json['event_type'] as String? ?? ''),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      verified: json['verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'event_type': eventType.apiValue,
        'confidence': confidence,
      };
}
