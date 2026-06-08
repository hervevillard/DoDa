import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../core/audio_player.dart';
import '../core/content_loader.dart';
import '../models/word_model.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/reward_overlay.dart';
import '../widgets/african_decoration.dart';

class WordBuildingScreen extends StatefulWidget {
  final String levelId;
  const WordBuildingScreen({super.key, required this.levelId});

  @override
  State<WordBuildingScreen> createState() => _WordBuildingScreenState();
}

class _WordBuildingScreenState extends State<WordBuildingScreen> {
  List<WordModel> _words = [];
  int _currentWordIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _showReward = false;

  List<String> _shuffledLetters = [];
  List<String?> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final all = await ContentLoader.loadWords();
    setState(() {
      _words = (all..shuffle()).take(5).toList();
      _loading = false;
    });
    _setupWord();
  }

  void _setupWord() {
    if (_words.isEmpty) return;
    final word = _words[_currentWordIndex];
    setState(() {
      _slots = List.filled(word.letters.length, null);
      _shuffledLetters = List.from(word.letters)..shuffle();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      final lang = context.read<LanguageProvider>();
      context.read<DodaAudioPlayer>().playAsset(word.audioFor(lang.languageCode));
    });
  }

  void _onLetterPlaced(String letter, int slotIndex) {
    setState(() {
      _slots[slotIndex] = letter;
      _shuffledLetters.remove(letter);
    });
    _checkCompletion();
  }

  void _onLetterRemoved(int slotIndex) {
    final letter = _slots[slotIndex];
    if (letter == null) return;
    setState(() {
      _shuffledLetters.add(letter);
      _slots[slotIndex] = null;
    });
  }

  void _checkCompletion() {
    if (_slots.any((s) => s == null)) return;
    final word = _words[_currentWordIndex];
    final isCorrect = _slots.join() == word.letters.join();

    if (isCorrect) {
      _score++;
      context.read<DodaAudioPlayer>().playReward();
      setState(() => _showReward = true);
    } else {
      context.read<DodaAudioPlayer>().playEncouragement();
      Future.delayed(const Duration(milliseconds: 800), () {
        final w = _words[_currentWordIndex];
        setState(() {
          _slots = List.filled(w.letters.length, null);
          _shuffledLetters = List.from(w.letters)..shuffle();
        });
      });
    }
  }

  void _nextWord() {
    setState(() => _showReward = false);
    if (_currentWordIndex < _words.length - 1) {
      setState(() => _currentWordIndex++);
      _setupWord();
    } else {
      _completeLevel();
    }
  }

  Future<void> _completeLevel() async {
    final progress = context.read<ProgressManager>();
    final stars = _score >= 5 ? 3 : _score >= 3 ? 2 : 1;
    await progress.completeLevel(widget.levelId, stars);
    if (mounted) {
      context.read<DodaAudioPlayer>().playSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_loading || _words.isEmpty) {
      return Scaffold(
        body: ParchmentBackground(
          child: const Center(
              child: CircularProgressIndicator(color: kColorPrimary)),
        ),
      );
    }

    final word = _words[_currentWordIndex];
    final displayWord = lang.isEnglish ? word.wordEn : word.wordRw;

    return Scaffold(
      body: ParchmentBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  // ── Left panel: image + audio + mascot ───────────────────
                  _WordLeftPanel(
                    word: word,
                    wordIndex: _currentWordIndex,
                    total: _words.length,
                    score: _score,
                    lang: lang,
                    onBack: () => Navigator.pop(context),
                    onPlayAudio: () {
                      context
                          .read<DodaAudioPlayer>()
                          .playAsset(word.audioFor(lang.languageCode));
                    },
                  ),

                  // Divider
                  Container(
                    width: 2,
                    color: kColorSand,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                  ),

                  // ── Right panel: slots + tiles ────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Column(
                        children: [
                          // Giant word display — as large as possible so kids can see it
                          SizedBox(
                            height: 80,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                displayWord.toUpperCase(),
                                style: GoogleFonts.nunito(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                  color: kColorPrimary,
                                  letterSpacing: 8,
                                  shadows: [
                                    Shadow(
                                      color: kColorEarth.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(2, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const KenteDivider(height: 6),
                          const Spacer(),

                          // Letter slots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slots.length, (i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: DragTarget<String>(
                                  onAcceptWithDetails: (d) =>
                                      _onLetterPlaced(d.data, i),
                                  builder: (context, candidates, _) {
                                    final highlight = candidates.isNotEmpty;
                                    return GestureDetector(
                                      onTap: () => _onLetterRemoved(i),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        width: 62,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          color: highlight
                                              ? kColorAccent.withOpacity(0.35)
                                              : (_slots[i] != null
                                                  ? kColorSecondary
                                                      .withOpacity(0.15)
                                                  : Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: highlight
                                                ? kColorAccent
                                                : _slots[i] != null
                                                    ? kColorSecondary
                                                    : kColorSand,
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.06),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            )
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            _slots[i]?.toUpperCase() ?? '',
                                            style: GoogleFonts.nunito(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w900,
                                              color: kColorText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 28),

                          // Draggable letter tiles
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: _shuffledLetters.map((letter) {
                              return Draggable<String>(
                                data: letter,
                                feedback:
                                    _LetterTile(letter: letter, state: _TileState.dragging),
                                childWhenDragging:
                                    _LetterTile(letter: letter, state: _TileState.ghost),
                                child: _LetterTile(letter: letter),
                              );
                            }).toList(),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (_showReward)
                RewardOverlay(
                  stars: 3,
                  messageEn: displayWord,
                  messageRw: displayWord,
                  onDismiss: _nextWord,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left panel ────────────────────────────────────────────────────────────────

class _WordLeftPanel extends StatelessWidget {
  final WordModel word;
  final int wordIndex;
  final int total;
  final int score;
  final LanguageProvider lang;
  final VoidCallback onBack;
  final VoidCallback onPlayAudio;

  const _WordLeftPanel({
    required this.word,
    required this.wordIndex,
    required this.total,
    required this.score,
    required this.lang,
    required this.onBack,
    required this.onPlayAudio,
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
            kColorPrimary.withOpacity(0.12),
            kColorAccent.withOpacity(0.08),
          ],
        ),
        border: Border(right: BorderSide(color: kColorSand, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
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
                Text(
                  '${wordIndex + 1}/$total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kColorTextLight,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Word image placeholder
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: kColorAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kColorAccent.withOpacity(0.5), width: 2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, size: 56, color: kColorEarth),
                  Text(
                    'Image',
                    style: TextStyle(
                      color: kColorTextLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Mascot(size: 70, expression: MascotExpression.curious),

            const SizedBox(height: 10),

            // Score stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                return Icon(
                  i < score ? Icons.star_rounded : Icons.star_border_rounded,
                  color: i < score ? kColorStar : kColorLocked,
                  size: 18,
                );
              }),
            ),

            const SizedBox(height: 12),

            // Audio button
            GestureDetector(
              onTap: onPlayAudio,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: kColorPrimary.withOpacity(0.4), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.volume_up_rounded, color: kColorPrimary, size: 24),
                    SizedBox(width: 6),
                    Text('Listen',
                        style: TextStyle(
                            color: kColorPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
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

// ── Letter tile ───────────────────────────────────────────────────────────────

enum _TileState { normal, dragging, ghost }

// Kente-inspired rotating tile colors
const _kTileColors = [
  kColorKente3, // gold
  kColorKente2, // green
  kColorKente1, // red
  kColorAccent,
];

class _LetterTile extends StatelessWidget {
  final String letter;
  final _TileState state;

  const _LetterTile({required this.letter, this.state = _TileState.normal});

  @override
  Widget build(BuildContext context) {
    final colorIdx = letter.codeUnitAt(0) % _kTileColors.length;
    final baseColor = _kTileColors[colorIdx];

    final Color bg;
    final Color text;
    switch (state) {
      case _TileState.dragging:
        bg = kColorPrimary;
        text = Colors.white;
      case _TileState.ghost:
        bg = baseColor.withOpacity(0.25);
        text = kColorText.withOpacity(0.3);
      case _TileState.normal:
        bg = baseColor;
        text = kColorText;
    }

    return Opacity(
      opacity: state == _TileState.ghost ? 0.35 : 1.0,
      child: Container(
        width: 62,
        height: 72,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: state == _TileState.dragging
              ? [
                  const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 14,
                      offset: Offset(0, 7))
                ]
              : [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
          border: Border.all(
            color: state == _TileState.normal
                ? Colors.white.withOpacity(0.4)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}
