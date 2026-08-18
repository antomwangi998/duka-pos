import 'package:audioplayers/audioplayers.dart';

/// Plays short audio cues when the scanner picks up a barcode, in addition
/// to the existing haptic vibration feedback. Uses a dedicated low-latency
/// player so the beep fires immediately on each scan.
class ScanFeedbackHelper {
  ScanFeedbackHelper._internal();
  static final ScanFeedbackHelper _instance = ScanFeedbackHelper._internal();
  factory ScanFeedbackHelper() => _instance;

  // AudioPlayer's default AssetSource prefix is 'assets/', so a source of
  // 'sounds/scan_success.wav' resolves to 'assets/sounds/scan_success.wav',
  // matching the asset declared in pubspec.yaml.
  final AudioPlayer _player = AudioPlayer(playerId: 'scan_feedback');

  Future<void> playSuccess() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/scan_success.wav'),
          mode: PlayerMode.lowLatency, volume: 0.8);
    } catch (_) {
      // Sound is a nice-to-have; never let audio errors break scanning.
    }
  }

  Future<void> playError() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/scan_error.wav'),
          mode: PlayerMode.lowLatency, volume: 0.6);
    } catch (_) {
      // Sound is a nice-to-have; never let audio errors break scanning.
    }
  }
}
