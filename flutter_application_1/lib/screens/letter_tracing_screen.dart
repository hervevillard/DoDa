import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../core/audio_player.dart';
import '../core/content_loader.dart';
import '../models/letter_model.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/tracing_canvas.dart';
import '../widgets/reward_overlay.dart';

class LetterTracingScreen extends StatefulWidget {
  final String levelId;
  final int startLetter;
  final int endLetter;

  const LetterTracingScreen({
    super.key,
    required this.levelId,
    required this.startLetter,
    required this.endLetter,
  });

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  List<LetterModel> _letters = [];
  int _currentIndex = 0;
  int _starsEarned = 0;
  bool _showReward = false;
  bool _loading = true;
  MascotExpression _mascotExpression = MascotExpression.happy;

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    final lang = context.read<LanguageProvider>();
    final all = await ContentLoader.loadLetters(lang.languageCode);
    setState(() {
      _letters = all.skip(widget.startLetter)
          .take(widget.endLetter - widget.startLetter + 1)
          .toList();
      _loading = false;
    });
    _playCurrentLetterAudio();
  }

  void _playCurrentLetterAudio() {
    if (_letters.isEmpty) return;
    final audio = context.read<DodaAudioPlayer>();
    audio.playAsset(_letters[_currentIndex].audioFile);
  }

  void _onTracingComplete(double accuracy) {
    final audio = context.read<DodaAudioPlayer>();
    final stars = accuracy > 0.8 ? 3 : accuracy > 0.5 ? 2 : 1;
    _starsEarned += stars;

    setState(() {
      _mascotExpression = MascotExpression.celebrating;
      _showReward = true;
    });
    audio.playReward();
  }

  void _nextLetter() {
    setState(() {
      _showReward = false;
      _mascotExpression = MascotExpression.happy;
    });

    if (_currentIndex < _letters.length - 1) {
      setState(() => _currentIndex++);
      _playCurrentLetterAudio();
    } else {
      _completeLevelAndExit();
    }
  }

  Future<void> _completeLevelAndExit() async {
    final progress = context.read<ProgressManager>();
    final avgStars = (_starsEarned / _letters.length).round().clamp(1, 3);
    await progress.completeLevel(widget.levelId, avgStars);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final letter = _letters[_currentIndex];

    return Scaffold(
      body: Container(
        color: kColorBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  // Left panel — mascot + info
                  SizedBox(
                    width: 220,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              Text(
                                '${_currentIndex + 1}/${_letters.length}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: kColorTextLight,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Mascot(size: 120, expression: _mascotExpression),
                          const SizedBox(height: 16),
                          Text(
                            letter.soundDescription,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: kColorTextLight,
                                ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _playCurrentLetterAudio,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kColorSecondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.volume_up, color: kColorSecondary, size: 32),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  // Right panel — tracing canvas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            lang.localizedText(
                              en: 'Trace the letter!',
                              rw: 'Kora inyuguti!',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TracingCanvas(
                              letter: letter,
                              onComplete: _onTracingComplete,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (_showReward)
                RewardOverlay(
                  stars: 3,
                  messageEn: 'Amazing!',
                  messageRw: 'Wakoze neza!',
                  onDismiss: _nextLetter,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
