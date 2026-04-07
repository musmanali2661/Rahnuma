/// Represents a single route step (maneuver instruction).
class RouteStep {
  const RouteStep({
    required this.distance,
    required this.duration,
    required this.instruction,
    required this.maneuverType,
    this.streetName,
    this.bearing,
  });

  final double distance;
  final double duration;
  final String instruction;
  final String maneuverType;
  final String? streetName;
  final double? bearing;

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    return RouteStep(
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      instruction: maneuver['instruction'] as String? ?? '',
      maneuverType: maneuver['type'] as String? ?? 'straight',
      streetName: json['name'] as String?,
      bearing: (maneuver['bearing_after'] as num?)?.toDouble(),
    );
  }
}

/// Represents a complete route returned by the routing engine.
class RouteModel {
  const RouteModel({
    required this.id,
    required this.distance,
    required this.duration,
    required this.geometry,
    required this.steps,
    this.tollEstimatePkr,
    this.summary,
  });

  final String id;

  /// Total distance in metres.
  final double distance;

  /// Total duration in seconds.
  final double duration;

  /// Encoded polyline or GeoJSON geometry string.
  final dynamic geometry;

  final List<RouteStep> steps;
  final double? tollEstimatePkr;
  final String? summary;

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final legs = (json['legs'] as List<dynamic>?) ?? [];
    final steps = legs.isEmpty
        ? <RouteStep>[]
        : (legs[0]['steps'] as List<dynamic>? ?? [])
            .map((s) => RouteStep.fromJson(s as Map<String, dynamic>))
            .toList();

    return RouteModel(
      id: json['id'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      geometry: json['geometry'],
      steps: steps,
      tollEstimatePkr: (json['toll_estimate_pkr'] as num?)?.toDouble(),
      summary: json['summary'] as String?,
    );
  }

  /// Formatted distance string (e.g. "1.2 km" or "800 m").
  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.toInt()} m';
  }

  /// Formatted duration string (e.g. "5 min" or "1 hr 10 min").
  String get formattedDuration {
    final totalMinutes = (duration / 60).round();
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return mins > 0 ? '$hours hr $mins min' : '$hours hr';
  }
}
