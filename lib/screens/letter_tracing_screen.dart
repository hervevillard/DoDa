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
  int _totalStarsEarned = 0;
  int _lastStars = 3;
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
      _letters = all
          .skip(widget.startLetter)
          .take(widget.endLetter - widget.startLetter + 1)
          .toList();
      _loading = false;
    });
    _playCurrentLetterAudio();
  }

  void _playCurrentLetterAudio() {
    if (_letters.isEmpty) return;
    context.read<DodaAudioPlayer>().playAsset(_letters[_currentIndex].audioFile);
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
    final avgStars = (_totalStarsEarned / _letters.length).round().clamp(1, 3);
    await progress.completeLevel(widget.levelId, avgStars);
    if (mounted) {
      context.read<DodaAudioPlayer>().playSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_loading) {
      return Scaffold(
        body: ParchmentBackground(
          child: const Center(
            child: CircularProgressIndicator(color: kColorPrimary),
          ),
        ),
      );
    }

    final letter = _letters[_currentIndex];

    return Scaffold(
      body: ParchmentBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  // ── Left panel ───────────────────────────────────────────
                  _LeftPanel(
                    letter: letter,
                    currentIndex: _currentIndex,
                    total: _letters.length,
                    expression: _mascotExpression,
                    lang: lang,
                    onPlayAudio: _playCurrentLetterAudio,
                    onBack: () => Navigator.pop(context),
                  ),

                  // ── Vertical divider ─────────────────────────────────────
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
                          // Instruction header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: kColorPrimary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: kColorPrimary.withOpacity(0.3)),
                            ),
                            child: Text(
                              lang.localizedText(
                                en: 'Trace the letter  ${letter.letter}',
                                rw: 'Kora inyuguti  ${letter.letter}',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: kColorPrimary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TracingCanvas(
                              key: ValueKey(letter.id),
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

              // Reward overlay
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
                  onDismiss: _nextLetter,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left info panel ───────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  final LetterModel letter;
  final int currentIndex;
  final int total;
  final MascotExpression expression;
  final LanguageProvider lang;
  final VoidCallback onPlayAudio;
  final VoidCallback onBack;

  const _LeftPanel({
    required this.letter,
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
            kColorPrimary.withOpacity(0.15),
            kColorPrimary.withOpacity(0.05),
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
            // Nav row
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kColorPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: kColorPrimary),
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

            // Giant letter display
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
                  letter.letter,
                  style: GoogleFonts.nunito(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: kColorPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Mascot(size: 90, expression: expression),

            const SizedBox(height: 10),

            // Sound description
            Text(
              letter.soundDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: kColorTextLight,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 12),

            // Play audio button
            GestureDetector(
              onTap: onPlayAudio,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: kColorSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: kColorSecondary.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.volume_up_rounded,
                        color: kColorSecondary, size: 26),
                    SizedBox(width: 6),
                    Text('Listen',
                        style: TextStyle(
                            color: kColorSecondary,
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
