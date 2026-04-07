/// A road event (pothole, speed bump, rough road) from the backend or ML service.
class RoadEvent {
  final String? id;
  final String eventType;
  final double confidence;
  final double lat;
  final double lon;
  final bool verified;

  const RoadEvent({
    this.id,
    required this.eventType,
    required this.confidence,
    required this.lat,
    required this.lon,
    this.verified = false,
  });

  factory RoadEvent.fromJson(Map<String, dynamic> json) {
    return RoadEvent(
      id: json['id'] as String?,
      eventType: json['event_type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'event_type': eventType,
        'confidence': confidence,
        'lat': lat,
        'lon': lon,
      };
}

/// An offline map package (city-level MBTiles).
class OfflinePackage {
  final String id;
  final String name;
  final int sizeMb;
  final bool available;
  final int? fileSizeBytes;
  final String? lastUpdated;

  const OfflinePackage({
    required this.id,
    required this.name,
    required this.sizeMb,
    required this.available,
    this.fileSizeBytes,
    this.lastUpdated,
  });

  factory OfflinePackage.fromJson(Map<String, dynamic> json) {
    return OfflinePackage(
      id: json['id'] as String,
      name: json['name'] as String,
      sizeMb: (json['size_mb'] as num).toInt(),
      available: json['available'] as bool? ?? false,
      fileSizeBytes: json['file_size_bytes'] as int?,
      lastUpdated: json['last_updated'] as String?,
    );
  }
}
