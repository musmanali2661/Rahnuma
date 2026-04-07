import 'package:flutter_test/flutter_test.dart';
import 'package:rahnuma/models/route_model.dart';
import 'package:rahnuma/models/search_result.dart';
import 'package:rahnuma/models/road_event.dart';

void main() {
  group('SearchResult.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'place_id': 42,
        'name': 'Lahore, Punjab, Pakistan',
        'lat': 31.5204,
        'lon': 74.3587,
        'type': 'city',
        'class': 'place',
        'address': {'city': 'Lahore'},
      };
      final result = SearchResult.fromJson(json);
      expect(result.placeId, 42);
      expect(result.name, 'Lahore, Punjab, Pakistan');
      expect(result.lat, closeTo(31.5204, 0.0001));
      expect(result.lon, closeTo(74.3587, 0.0001));
      expect(result.type, 'city');
      expect(result.category, 'place');
    });

    test('handles missing optional fields', () {
      final json = {
        'place_id': 1,
        'name': 'Test',
        'lat': 30.0,
        'lon': 70.0,
      };
      final result = SearchResult.fromJson(json);
      expect(result.type, isNull);
      expect(result.category, isNull);
      expect(result.address, isEmpty);
    });
  });

  group('RouteModel.fromJson', () {
    test('parses distance, duration and geometry', () {
      final json = {
        'distance': 350000.0,
        'duration': 12600.0,
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [74.3, 31.5],
            [73.0, 33.7],
          ],
        },
        'legs': [
          {
            'distance': 350000.0,
            'duration': 12600.0,
            'summary': 'M-2',
            'steps': [
              {
                'distance': 1000.0,
                'duration': 60.0,
                'name': 'Test Road',
                'mode': 'driving',
                'maneuver': {'type': 'depart', 'modifier': ''},
              },
            ],
          },
        ],
        'summary': 'M-2',
        'toll_estimate_pkr': 685,
      };

      final route = RouteModel.fromJson(json);
      expect(route.distance, 350000.0);
      expect(route.duration, 12600.0);
      expect(route.geometry.coordinates.length, 2);
      expect(route.geometry.coordinates[0].latitude, closeTo(31.5, 0.001));
      expect(route.geometry.coordinates[0].longitude, closeTo(74.3, 0.001));
      expect(route.legs.length, 1);
      expect(route.legs[0].steps.length, 1);
      expect(route.tollEstimatePkr, 685);
    });

    test('allSteps flattens steps across legs', () {
      final step = {
        'distance': 100.0,
        'duration': 10.0,
        'name': 'Road',
        'mode': 'driving',
        'maneuver': {'type': 'straight', 'modifier': ''},
      };
      final json = {
        'distance': 200.0,
        'duration': 20.0,
        'geometry': {
          'type': 'LineString',
          'coordinates': [[74.0, 31.0], [74.1, 31.1]],
        },
        'legs': [
          {'distance': 100.0, 'duration': 10.0, 'summary': '', 'steps': [step]},
          {'distance': 100.0, 'duration': 10.0, 'summary': '', 'steps': [step]},
        ],
        'summary': '',
        'toll_estimate_pkr': 0,
      };
      final route = RouteModel.fromJson(json);
      expect(route.allSteps.length, 2);
    });
  });

  group('RoadEvent', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'abc-123',
        'event_type': 'pothole',
        'confidence': 0.85,
        'lat': 31.5,
        'lon': 74.3,
        'verified': true,
      };
      final ev = RoadEvent.fromJson(json);
      expect(ev.id, 'abc-123');
      expect(ev.eventType, 'pothole');
      expect(ev.confidence, closeTo(0.85, 0.001));
      expect(ev.verified, isTrue);
    });

    test('toJson round-trips correctly', () {
      const ev = RoadEvent(
        eventType: 'speed_bump',
        confidence: 0.75,
        lat: 30.0,
        lon: 70.0,
      );
      final json = ev.toJson();
      expect(json['event_type'], 'speed_bump');
      expect(json['confidence'], closeTo(0.75, 0.001));
      expect(json['lat'], 30.0);
      expect(json['lon'], 70.0);
    });
  });

  group('OfflinePackage.fromJson', () {
    test('parses available package', () {
      final json = {
        'id': 'karachi',
        'name': 'Karachi',
        'size_mb': 450,
        'available': true,
        'file_size_bytes': 471859200,
        'last_updated': '2026-01-01T00:00:00.000Z',
      };
      final pkg = OfflinePackage.fromJson(json);
      expect(pkg.id, 'karachi');
      expect(pkg.sizeMb, 450);
      expect(pkg.available, isTrue);
      expect(pkg.fileSizeBytes, 471859200);
    });

    test('parses unavailable package', () {
      final json = {
        'id': 'lahore',
        'name': 'Lahore',
        'size_mb': 380,
        'available': false,
      };
      final pkg = OfflinePackage.fromJson(json);
      expect(pkg.available, isFalse);
      expect(pkg.fileSizeBytes, isNull);
    });
  });
}
