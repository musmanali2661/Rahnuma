import 'package:audioplayers/audioplayers.dart';

/// Maps OSRM maneuver types to the corresponding Urdu audio asset names.
const Map<String, String> _kUrduAudioAssets = {
  'turn right': 'audio/urdu_voice/turn_right.mp3',
  'turn left': 'audio/urdu_voice/turn_left.mp3',
  'straight': 'audio/urdu_voice/straight.mp3',
  'continue': 'audio/urdu_voice/straight.mp3',
  'new name': 'audio/urdu_voice/straight.mp3',
  'arrive': 'audio/urdu_voice/destination_reached.mp3',
  'speed_bump': 'audio/urdu_voice/speed_breaker.mp3',
};

/// Provides turn-by-turn voice guidance using pre-recorded Urdu audio files.
///
/// Falls back to no audio for maneuver types that do not have a recording.
class VoiceService {
  final AudioPlayer _player = AudioPlayer();

  /// Play the Urdu voice instruction for [maneuverType].
  ///
  /// Returns true if a matching audio file was found and played,
  /// false if there is no recording for that maneuver type.
  Future<bool> announceManeuver(String maneuverType) async {
    final asset = _kUrduAudioAssets[maneuverType.toLowerCase()];
    if (asset == null) return false;

    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Play the speed-breaker (speed bump) warning audio.
  Future<void> announceSpeedBreaker() async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('audio/urdu_voice/speed_breaker.mp3'),
      );
    } catch (_) {}
  }

  /// Play the destination-reached audio.
  Future<void> announceDestinationReached() async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('audio/urdu_voice/destination_reached.mp3'),
      );
    } catch (_) {}
  }

  /// Release audio resources.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
