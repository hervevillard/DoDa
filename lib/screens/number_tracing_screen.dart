import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../widgets/african_decoration.dart';

class NumberTracingScreen extends StatefulWidget {
  final String levelId;

  const NumberTracingScreen({super.key, required this.levelId});

  @override
  State<NumberTracingScreen> createState() => _NumberTracingScreenState();
}

class _NumberTracingScreenState extends State<NumberTracingScreen> {
  List<LetterModel> _numbers = [];
  int _currentIndex = 0;
  int _totalStarsEarned = 0;
  int _lastStars = 3;
  bool _showReward = false;
  bool _loading = true;
  MascotExpression _mascotExpression = MascotExpression.happy;

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    final all = await ContentLoader.loadNumbers();
    setState(() {
      _numbers = all;
      _loading = false;
    });
    _playCurrentAudio();
  }

  void _playCurrentAudio() {
    if (_numbers.isEmpty) return;
    context.read<DodaAudioPlayer>().playAsset(_numbers[_currentIndex].audioFile);
  }

  void _onTracingComplete(double accuracy) {
    final stars = accuracy > 0.8 ? 3 : accuracy > 0.5 ? 2 : 1;
    _lastStars = stars;
    _totalStarsEarned += stars;
    setState(() {
      _mascotExpression = MascotExpression.celebrating;
      _showReward = true;
    });
    context.read<DodaAudioPlayer>().playReward();
  }

  void _nextNumber() {
    setState(() {
      _showReward = false;
      _mascotExpression = MascotExpression.happy;
    });

    if (_currentIndex < _numbers.length - 1) {
      setState(() => _currentIndex++);
      _playCurrentAudio();
    } else {
      _completeLevelAndExit();
    }
  }

  Future<void> _completeLevelAndExit() async {
    final progress = context.read<ProgressManager>();
    final avgStars = (_totalStarsEarned / _numbers.length).round().clamp(1, 3);
    await progress.completeLevel(widget.levelId, avgStars);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_loading) {
      return Scaffold(
        body: ParchmentBackground(
          child: const Center(
            child: CircularProgressIndicator(color: kColorAccent),
          ),
        ),
      );
    }

    final number = _numbers[_currentIndex];

    return Scaffold(
      body: ParchmentBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  // ── Left panel ───────────────────────────────────────────
                  _NumberLeftPanel(
                    number: number,
                    currentIndex: _currentIndex,
                    total: _numbers.length,
                    expression: _mascotExpression,
                    lang: lang,
                    onPlayAudio: _playCurrentAudio,
                    onBack: () => Navigator.pop(context),
                  ),

                  Container(
                    width: 3,
                    color: kColorSand,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                  ),

                  // ── Right panel — tracing canvas ──────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: kColorAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: kColorAccent.withOpacity(0.3)),
                            ),
                            child: Text(
                              lang.localizedText(
                                en: 'Trace the number  ${number.letter}',
                                rw: 'Kora umubare  ${number.letter}',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: kColorAccent),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TracingCanvas(
                              key: ValueKey('num_${number.id}'),
                              letter: number,
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
                  stars: _lastStars,
                  messageEn: _lastStars == 3
                      ? 'Amazing! ⭐'
                      : _lastStars == 2
                          ? 'Good job!'
                          : 'Keep trying!',
                  messageRw: _lastStars == 3
                      ? 'Wakoze neza!'
                      : _lastStars == 2
                          ? 'Byiza!'
                          : 'Komeza!',
                  onDismiss: _nextNumber,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left info panel ───────────────────────────────────────────────────────────

class _NumberLeftPanel extends StatelessWidget {
  final LetterModel number;
  final int currentIndex;
  final int total;
  final MascotExpression expression;
  final LanguageProvider lang;
  final VoidCallback onPlayAudio;
  final VoidCallback onBack;

  const _NumberLeftPanel({
    required this.number,
    required this.currentIndex,
    required this.total,
    required this.expression,
    required this.lang,
    required this.onPlayAudio,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kColorAccent.withOpacity(0.15),
            kColorAccent.withOpacity(0.05),
          ],
        ),
        border: Border(
          right: BorderSide(color: kColorSand, width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kColorAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: kColorAccent),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kColorEarth.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentIndex + 1} / $total',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kColorTextLight,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kColorAccent.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(color: kColorAccent, width: 3),
              ),
              child: Center(
                child: Text(
                  number.letter,
                  style: GoogleFonts.nunito(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: kColorAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Mascot(size: 90, expression: expression),

            const SizedBox(height: 10),

            Text(
              number.soundDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: kColorTextLight,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: onPlayAudio,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: kColorAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: kColorAccent.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.volume_up_rounded, color: kColorAccent, size: 26),
                    SizedBox(width: 6),
                    Text('Listen',
                        style: TextStyle(
                            color: kColorAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
