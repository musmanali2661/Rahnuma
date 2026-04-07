import 'package:audioplayers/audioplayers.dart';

/// Maps navigation maneuver types to Urdu audio clips and plays them.
class VoiceService {
  VoiceService._();

  static final VoiceService instance = VoiceService._();

  final AudioPlayer _player = AudioPlayer();

  bool _muted = false;
  bool get isMuted => _muted;

  void toggleMute() => _muted = !_muted;
  void setMuted(bool value) => _muted = value;

  /// Play the appropriate voice clip for a maneuver type.
  ///
  /// [maneuverType] mirrors OSRM maneuver types:
  /// `turn left`, `turn right`, `straight`, `arrive`, `speed_breaker`
  Future<void> playManeuver(String maneuverType) async {
    if (_muted) return;
    final asset = _assetForManeuver(maneuverType);
    if (asset != null) {
      await _player.stop();
      await _player.play(AssetSource(asset));
    }
  }

  Future<void> playDestinationReached() async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource('audio/urdu_voice/destination_reached.mp3'));
  }

  Future<void> playSpeedBreaker() async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource('audio/urdu_voice/speed_breaker.mp3'));
  }

  Future<void> playTurnLeft() async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource('audio/urdu_voice/turn_left.mp3'));
  }

  Future<void> playTurnRight() async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource('audio/urdu_voice/turn_right.mp3'));
  }

  Future<void> playStraight() async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource('audio/urdu_voice/straight.mp3'));
  }

  String? _assetForManeuver(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('left')) return 'audio/urdu_voice/turn_left.mp3';
    if (lower.contains('right')) return 'audio/urdu_voice/turn_right.mp3';
    if (lower.contains('straight') || lower.contains('continue')) {
      return 'audio/urdu_voice/straight.mp3';
    }
    if (lower.contains('arrive') || lower.contains('destination')) {
      return 'audio/urdu_voice/destination_reached.mp3';
    }
    if (lower.contains('speed') || lower.contains('bump')) {
      return 'audio/urdu_voice/speed_breaker.mp3';
    }
    return null;
  }

  void dispose() => _player.dispose();
}
