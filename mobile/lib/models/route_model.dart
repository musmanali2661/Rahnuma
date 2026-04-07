import 'package:latlong2/latlong.dart';

/// A route returned by the OSRM backend.
class RouteModel {
  final double distance;
  final double duration;
  final RouteGeometry geometry;
  final List<RouteLeg> legs;
  final String summary;
  final int tollEstimatePkr;

  const RouteModel({
    required this.distance,
    required this.duration,
    required this.geometry,
    required this.legs,
    required this.summary,
    required this.tollEstimatePkr,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      geometry: RouteGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
      legs: (json['legs'] as List<dynamic>)
          .map((l) => RouteLeg.fromJson(l as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String? ?? '',
      tollEstimatePkr: (json['toll_estimate_pkr'] as num? ?? 0).toInt(),
    );
  }

  /// All steps across all legs, flattened.
  List<RouteStep> get allSteps =>
      legs.expand((leg) => leg.steps).toList();
}

class RouteGeometry {
  final String type;
  final List<LatLng> coordinates;

  const RouteGeometry({required this.type, required this.coordinates});

  factory RouteGeometry.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['coordinates'] as List<dynamic>;
    final coords = rawCoords.map((c) {
      final pair = c as List<dynamic>;
      // GeoJSON order: [longitude, latitude]
      return LatLng(
        (pair[1] as num).toDouble(),
        (pair[0] as num).toDouble(),
      );
    }).toList();
    return RouteGeometry(
      type: json['type'] as String,
      coordinates: coords,
    );
  }
}

class RouteLeg {
  final double distance;
  final double duration;
  final String summary;
  final List<RouteStep> steps;

  const RouteLeg({
    required this.distance,
    required this.duration,
    required this.summary,
    required this.steps,
  });

  factory RouteLeg.fromJson(Map<String, dynamic> json) {
    return RouteLeg(
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      summary: json['summary'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((s) => RouteStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RouteStep {
  final double distance;
  final double duration;
  final String name;
  final String mode;
  final StepManeuver maneuver;
  final RouteGeometry? geometry;

  const RouteStep({
    required this.distance,
    required this.duration,
    required this.name,
    required this.mode,
    required this.maneuver,
    this.geometry,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      mode: json['mode'] as String? ?? 'driving',
      maneuver: StepManeuver.fromJson(
          json['maneuver'] as Map<String, dynamic>? ?? {}),
      geometry: json['geometry'] != null
          ? RouteGeometry.fromJson(json['geometry'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StepManeuver {
  final String type;
  final String modifier;
  final List<double>? location;

  const StepManeuver({
    required this.type,
    required this.modifier,
    this.location,
  });

  factory StepManeuver.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as List<dynamic>?;
    return StepManeuver(
      type: json['type'] as String? ?? 'straight',
      modifier: json['modifier'] as String? ?? '',
      location: loc != null
          ? loc.map((v) => (v as num).toDouble()).toList()
          : null,
    );
  }
}
