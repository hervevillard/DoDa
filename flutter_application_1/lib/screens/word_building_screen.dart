import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../core/audio_player.dart';
import '../core/content_loader.dart';
import '../models/word_model.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/reward_overlay.dart';

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
      final audio = context.read<DodaAudioPlayer>();
      audio.playAsset(word.audioFor(lang.languageCode));
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
        setState(() {
          _slots = List.filled(word.letters.length, null);
          _shuffledLetters = List.from(word.letters)..shuffle();
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
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_loading || _words.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = _words[_currentWordIndex];
    final displayWord = lang.isEnglish ? word.wordEn : word.wordRw;

    return Scaffold(
      body: Container(
        color: kColorBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            lang.localizedText(
                              en: 'Build the word!',
                              rw: 'Injiza amagambo!',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text('${_currentWordIndex + 1}/${_words.length}'),
                      ],
                    ),
                  ),

                  // Word image + audio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: kColorSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.image, size: 60, color: kColorSecondary),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<DodaAudioPlayer>().playAsset(
                                    word.audioFor(lang.languageCode));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kColorPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.volume_up, color: kColorPrimary, size: 32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Mascot(size: 60, expression: MascotExpression.curious),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Letter slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slots.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: DragTarget<String>(
                          onAcceptWithDetails: (details) =>
                              _onLetterPlaced(details.data, i),
                          builder: (context, candidateData, rejectedData) {
                            final isHighlighted = candidateData.isNotEmpty;
                            return GestureDetector(
                              onTap: () => _onLetterRemoved(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 60,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: isHighlighted
                                      ? kColorAccent.withOpacity(0.4)
                                      : (_slots[i] != null
                                          ? kColorSecondary.withOpacity(0.2)
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isHighlighted ? kColorAccent : kColorTextLight.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _slots[i]?.toUpperCase() ?? '',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
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

                  const SizedBox(height: 40),

                  // Draggable letter tiles
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _shuffledLetters.map((letter) {
                      return Draggable<String>(
                        data: letter,
                        feedback: _LetterTile(letter: letter, isDragging: true),
                        childWhenDragging: _LetterTile(letter: letter, isDragging: true, ghost: true),
                        child: _LetterTile(letter: letter),
                      );
                    }).toList(),
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

class _LetterTile extends StatelessWidget {
  final String letter;
  final bool isDragging;
  final bool ghost;

  const _LetterTile({
    required this.letter,
    this.isDragging = false,
    this.ghost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: ghost ? 0.3 : 1.0,
      child: Container(
        width: 60,
        height: 70,
        decoration: BoxDecoration(
          color: isDragging && !ghost ? kColorPrimary : kColorAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDragging && !ghost
              ? [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDragging && !ghost ? Colors.white : kColorText,
            ),
          ),
        ),
      ),
    );
  }
}
