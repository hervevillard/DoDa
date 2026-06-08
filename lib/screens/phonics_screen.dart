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
import '../widgets/reward_overlay.dart';
import '../widgets/african_decoration.dart';

class PhonicsScreen extends StatefulWidget {
  final String levelId;
  const PhonicsScreen({super.key, required this.levelId});

  @override
  State<PhonicsScreen> createState() => _PhonicsScreenState();
}

class _PhonicsScreenState extends State<PhonicsScreen>
    with SingleTickerProviderStateMixin {
  List<LetterModel> _letters = [];
  int _currentRound = 0;
  int _score = 0;
  bool _loading = true;
  bool _showReward = false;
  String? _selectedId;
  late LetterModel _targetLetter;
  late List<LetterModel> _choices;

  late AnimationController _drumController;

  static const int kTotalRounds = 6;

  @override
  void initState() {
    super.initState();
    _drumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadLetters();
  }

  @override
  void dispose() {
    _drumController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    final lang = context.read<LanguageProvider>();
    final letters = await ContentLoader.loadLetters(lang.languageCode);
    setState(() {
      _letters = letters;
      _loading = false;
    });
    _setupRound();
  }

  void _refresh() {
    setState(() {
      _currentRound = 0;
      _score = 0;
      _showReward = false;
    });
    _setupRound();
  }

  void _setupRound() {
    if (_letters.length < 4) return;
    _letters.shuffle();
    _targetLetter = _letters.first;
    _choices = _letters.take(4).toList()..shuffle();
    _selectedId = null;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.read<DodaAudioPlayer>().playAsset(_targetLetter.audioFile);
    });
  }

  void _onDrumTap() {
    _drumController.forward(from: 0);
    context.read<DodaAudioPlayer>().playAsset(_targetLetter.audioFile);
  }

  void _onLetterTapped(LetterModel letter) {
    if (_selectedId != null) return;
    setState(() => _selectedId = letter.id);

    final isCorrect = letter.id == _targetLetter.id;
    final audio = context.read<DodaAudioPlayer>();

    if (isCorrect) {
      _score++;
      audio.playReward();
      setState(() => _showReward = true);
    } else {
      audio.playEncouragement();
      Future.delayed(const Duration(seconds: 1), _nextRound);
    }
  }

  void _nextRound() {
    setState(() => _showReward = false);
    if (_currentRound < kTotalRounds - 1) {
      setState(() => _currentRound++);
      _setupRound();
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

    if (_loading || _letters.length < 4) {
      return Scaffold(
        body: ParchmentBackground(
          child: const Center(
              child: CircularProgressIndicator(color: kColorPrimary)),
        ),
      );
    }

    return Scaffold(
      body: ParchmentBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  // ── Left panel: drum + mascot ─────────────────────────────
                  _PhonicsLeftPanel(
                    round: _currentRound,
                    total: kTotalRounds,
                    score: _score,
                    lang: lang,
                    drumController: _drumController,
                    onBack: () => Navigator.pop(context),
                    onDrumTap: _onDrumTap,
                    onRefresh: _refresh,
                  ),

                  // Divider
                  Container(
                    width: 2,
                    color: kColorSand,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                  ),

                  // ── Right panel: letter choices ───────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            lang.localizedText(
                              en: 'Which letter makes this sound?',
                              rw: 'Ni inyuguti iyihe ifite iri jwi?',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: kColorText),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1.6,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              children: _choices.map((letter) {
                                return _ChoiceTile(
                                  letter: letter,
                                  selectedId: _selectedId,
                                  targetId: _targetLetter.id,
                                  onTap: () => _onLetterTapped(letter),
                                );
                              }).toList(),
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
                  messageEn: 'Correct!',
                  messageRw: 'Ni yo!',
                  onDismiss: _nextRound,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left panel ────────────────────────────────────────────────────────────────

class _PhonicsLeftPanel extends StatelessWidget {
  final int round;
  final int total;
  final int score;
  final LanguageProvider lang;
  final AnimationController drumController;
  final VoidCallback onBack;
  final VoidCallback onDrumTap;
  final VoidCallback onRefresh;

  const _PhonicsLeftPanel({
    required this.round,
    required this.total,
    required this.score,
    required this.lang,
    required this.drumController,
    required this.onBack,
    required this.onDrumTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kColorSecondary.withOpacity(0.18),
            kColorSecondary.withOpacity(0.06),
          ],
        ),
        border: Border(right: BorderSide(color: kColorSand, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            // Nav row
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kColorSecondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: kColorSecondary),
                  ),
                ),
                const Spacer(),
                Text(
                  '${round + 1}/$total',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kColorTextLight,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kColorAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shuffle_rounded,
                        size: 20, color: kColorEarth),
                  ),
                ),
              ],
            ),

            const Spacer(),

            const Mascot(size: 80, expression: MascotExpression.curious),

            const SizedBox(height: 16),

            // Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                return Icon(
                  i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < score ? kColorStar : kColorTextLight.withOpacity(0.4),
                  size: 22,
                );
              }),
            ),

            const SizedBox(height: 20),

            // African drum button
            GestureDetector(
              onTap: onDrumTap,
              child: AnimatedBuilder(
                animation: drumController,
                builder: (context, child) {
                  final scale = 1.0 + 0.12 * drumController.value * (1 - drumController.value) * 4;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF8B5E3C), Color(0xFF5C3A1E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kColorEarth.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: kColorAccent, width: 3),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note_rounded,
                          color: Colors.white, size: 36),
                      Text(
                        'TAP',
                        style: TextStyle(
                          color: kColorAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              lang.localizedText(en: 'Tap to hear!', rw: 'Kanda wumve!'),
              style: const TextStyle(
                fontSize: 13,
                color: kColorTextLight,
                fontStyle: FontStyle.italic,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Choice tile ───────────────────────────────────────────────────────────────

class _ChoiceTile extends StatelessWidget {
  final LetterModel letter;
  final String? selectedId;
  final String targetId;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.letter,
    required this.selectedId,
    required this.targetId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedId == letter.id;
    final isCorrect = letter.id == targetId;
    final revealed = selectedId != null;

    Color bgColor;
    Color textColor;
    Color borderColor;

    if (!revealed) {
      bgColor = kColorSurface;
      textColor = kColorText;
      borderColor = kColorSand;
    } else if (isSelected && isCorrect) {
      bgColor = kColorSuccess;
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isSelected && !isCorrect) {
      bgColor = const Color(0xFFE53935);
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (!isSelected && isCorrect && revealed) {
      bgColor = kColorSuccess.withOpacity(0.25);
      textColor = kColorSuccess;
      borderColor = kColorSuccess;
    } else {
      bgColor = kColorSurface;
      textColor = kColorTextLight.withOpacity(0.5);
      borderColor = kColorSand.withOpacity(0.5);
    }

    return GestureDetector(
      onTap: revealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter.letter,
            style: GoogleFonts.nunito(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
