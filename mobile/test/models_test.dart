import 'package:flutter_test/flutter_test.dart';
import 'package:rahnuma/data/models/route_model.dart';
import 'package:rahnuma/data/models/place_model.dart';
import 'package:rahnuma/data/models/road_event_model.dart';
import 'package:rahnuma/data/models/offline_package_model.dart';

void main() {
  group('RouteModel', () {
    test('fromJson parses distance and duration', () {
      final json = {
        'id': 'route-1',
        'distance': 5000.0,
        'duration': 600.0,
        'geometry': null,
        'legs': [
          {
            'steps': [
              {
                'distance': 500.0,
                'duration': 60.0,
                'name': 'Main Street',
                'maneuver': {
                  'type': 'turn right',
                  'instruction': 'Turn right onto Main Street',
                },
              },
            ],
          },
        ],
      };
      final route = RouteModel.fromJson(json);
      expect(route.id, 'route-1');
      expect(route.distance, 5000.0);
      expect(route.duration, 600.0);
      expect(route.steps.length, 1);
      expect(route.steps[0].maneuverType, 'turn right');
    });

    test('formattedDistance shows km for distances >= 1000m', () {
      const route = RouteModel(
        id: 'r1',
        distance: 12345,
        duration: 900,
        geometry: null,
        steps: [],
      );
      expect(route.formattedDistance, '12.3 km');
    });

    test('formattedDistance shows m for distances < 1000m', () {
      const route = RouteModel(
        id: 'r1',
        distance: 450,
        duration: 90,
        geometry: null,
        steps: [],
      );
      expect(route.formattedDistance, '450 m');
    });

    test('formattedDuration shows minutes', () {
      const route = RouteModel(
        id: 'r1',
        distance: 1000,
        duration: 300, // 5 minutes
        geometry: null,
        steps: [],
      );
      expect(route.formattedDuration, '5 min');
    });

    test('formattedDuration shows hours and minutes', () {
      const route = RouteModel(
        id: 'r1',
        distance: 100000,
        duration: 4500, // 1 hr 15 min
        geometry: null,
        steps: [],
      );
      expect(route.formattedDuration, '1 hr 15 min');
    });
  });

  group('PlaceModel', () {
    test('fromJson handles flat Nominatim response', () {
      final json = {
        'place_id': '12345',
        'display_name': 'Liberty Chowk, Lahore',
        'lat': '31.5204',
        'lon': '74.3587',
        'category': 'landmark',
      };
      // Flat lat/lon are stored as strings in Nominatim
      final place = PlaceModel(
        id: '12345',
        name: 'Liberty Chowk, Lahore',
        lat: 31.5204,
        lon: 74.3587,
        category: 'landmark',
      );
      expect(place.name, 'Liberty Chowk, Lahore');
      expect(place.lat, 31.5204);
      expect(place.lon, 74.3587);
    });

    test('fromJson handles GeoJSON feature', () {
      final json = {
        'geometry': {
          'type': 'Point',
          'coordinates': [74.3587, 31.5204],
        },
        'properties': {
          'place_id': '99',
          'name': 'Badshahi Mosque',
          'name_ur': 'بادشاہی مسجد',
          'category': 'mosque',
        },
      };
      final place = PlaceModel.fromJson(json);
      expect(place.name, 'Badshahi Mosque');
      expect(place.nameUr, 'بادشاہی مسجد');
      expect(place.lat, closeTo(31.5204, 0.0001));
      expect(place.lon, closeTo(74.3587, 0.0001));
    });
  });

  group('RoadEventModel', () {
    test('fromJson parses event type and confidence', () {
      final json = {
        'id': 'evt-1',
        'geojson': {
          'type': 'Point',
          'coordinates': [74.36, 31.52],
        },
        'event_type': 'pothole',
        'confidence': 0.87,
        'verified': true,
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final event = RoadEventModel.fromJson(json);
      expect(event.eventType, RoadEventType.pothole);
      expect(event.confidence, closeTo(0.87, 0.001));
      expect(event.verified, isTrue);
      expect(event.lat, closeTo(31.52, 0.001));
      expect(event.lon, closeTo(74.36, 0.001));
    });

    test('toJson serialises correctly', () {
      const event = RoadEventModel(
        lat: 31.52,
        lon: 74.36,
        eventType: RoadEventType.speedBump,
        confidence: 0.75,
      );
      final json = event.toJson();
      expect(json['lat'], 31.52);
      expect(json['lon'], 74.36);
      expect(json['event_type'], 'speed_bump');
      expect(json['confidence'], 0.75);
    });

    test('RoadEventType apiValue returns correct strings', () {
      expect(RoadEventType.pothole.apiValue, 'pothole');
      expect(RoadEventType.speedBump.apiValue, 'speed_bump');
      expect(RoadEventType.roughRoad.apiValue, 'rough_road');
    });
  });

  group('OfflinePackage', () {
    test('fromJson parses city and sizeMb', () {
      final json = {
        'city': 'lahore',
        'display_name': 'Lahore',
        'size_mb': 125.5,
      };
      final pkg = OfflinePackage.fromJson(json);
      expect(pkg.city, 'lahore');
      expect(pkg.displayName, 'Lahore');
      expect(pkg.sizeMb, 125.5);
      expect(pkg.isDownloaded, isFalse);
    });

    test('copyWith updates isDownloaded', () {
      const pkg = OfflinePackage(
        city: 'karachi',
        displayName: 'Karachi',
        sizeMb: 200,
      );
      final updated = pkg.copyWith(isDownloaded: true);
      expect(updated.isDownloaded, isTrue);
      expect(updated.city, 'karachi');
    });
  });

  group('LatLon', () {
    test('toJson produces correct map', () {
      const latLon = LatLon(31.5204, 74.3587);
      expect(latLon.toJson(), {'lat': 31.5204, 'lon': 74.3587});
    });
  });
}
