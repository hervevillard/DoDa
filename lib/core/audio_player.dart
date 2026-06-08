import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

const _bgTracks = [
  'audio/background/Learn Loop.mp3',
];

class DodaAudioPlayer extends ChangeNotifier {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  bool _isMuted = false;
  bool _unlocked = !kIsWeb;
  int _bgIndex = 0;
  bool _bgStarted = false;

  bool get isMuted => _isMuted;

  void unlock() {
    _unlocked = true;
    _startBackground();
  }

  void _startBackground() {
    if (_bgStarted || _isMuted) return;
    _bgStarted = true;
    _bgPlayer.onPlayerComplete.listen((_) => _playNextTrack());
    _playNextTrack();
  }

  void _playNextTrack() async {
    if (_isMuted) return;
    try {
      await _bgPlayer.setVolume(0.2);
      await _bgPlayer.play(AssetSource(_bgTracks[_bgIndex]));
      _bgIndex = (_bgIndex + 1) % _bgTracks.length;
    } catch (_) {}
  }

  Future<void> playAsset(String assetPath) async {
    if (!_unlocked) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {}
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

  Future<void> pauseBackground() async {
    try {
      await _bgPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeBackground() async {
    if (_isMuted) return;
    try {
      await _bgPlayer.resume();
    } catch (_) {}
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgPlayer.stop();
    } else if (_unlocked) {
      _bgStarted = false;
      _startBackground();
    }
    notifyListeners();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _bgPlayer.dispose();
  }
}
