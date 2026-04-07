import 'package:flutter_test/flutter_test.dart';
import 'package:rahnuma/services/imu_service.dart';
import 'package:rahnuma/services/voice_service.dart';

void main() {
  group('ImuService', () {
    test('can be instantiated without error', () {
      expect(() => ImuService(), returnsNormally);
    });

    test('stop() is safe to call before start()', () {
      final service = ImuService();
      expect(() => service.stop(), returnsNormally);
    });

    test('currentLat and currentLon are null by default', () {
      final service = ImuService();
      expect(service.currentLat, isNull);
      expect(service.currentLon, isNull);
    });

    test('location fields can be assigned', () {
      final service = ImuService();
      service.currentLat = 31.5;
      service.currentLon = 74.3;
      expect(service.currentLat, 31.5);
      expect(service.currentLon, 74.3);
    });
  });

  group('VoiceService', () {
    test('can be instantiated without error', () {
      expect(() => VoiceService(), returnsNormally);
    });
  });

  group('Audio asset naming convention', () {
    const expectedAssets = [
      'audio/urdu_voice/turn_right.mp3',
      'audio/urdu_voice/turn_left.mp3',
      'audio/urdu_voice/straight.mp3',
      'audio/urdu_voice/destination_reached.mp3',
      'audio/urdu_voice/speed_breaker.mp3',
    ];

    for (final path in expectedAssets) {
      test('$path follows naming convention', () {
        expect(path, contains('urdu_voice'));
        expect(path, endsWith('.mp3'));
      });
    }
  });
}
