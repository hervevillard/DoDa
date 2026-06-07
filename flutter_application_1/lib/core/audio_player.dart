import 'package:audioplayers/audioplayers.dart';

class DodaAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> playAsset(String assetPath) async {
    if (_isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      // Audio file not found — silently skip during development
    }
  }

  Future<void> playReward() async {
    await playAsset('assets/audio/rewards/star.mp3');
  }

  Future<void> playSuccess() async {
    await playAsset('assets/audio/rewards/success.mp3');
  }

  Future<void> playEncouragement() async {
    await playAsset('assets/audio/rewards/encouragement.mp3');
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
