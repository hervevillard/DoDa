import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

const _bgTracks = [
  'audio/background/Felt Pockets.mp3',
  'audio/background/Learn Loop.mp3',
];

class DodaAudioPlayer {
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
      await _bgPlayer.play(AssetSource(_bgTracks[_bgIndex]));
      _bgIndex = (_bgIndex + 1) % _bgTracks.length;
    } catch (_) {}
  }

  Future<void> playAsset(String assetPath) async {
    if (_isMuted || !_unlocked) return;
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

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _sfxPlayer.stop();
      _bgPlayer.stop();
    } else if (_unlocked) {
      _bgStarted = false;
      _startBackground();
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _bgPlayer.dispose();
  }
}
