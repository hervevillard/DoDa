import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../core/audio_player.dart';
import '../core/content_loader.dart';
import '../models/letter_model.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/reward_overlay.dart';

class PhonicsScreen extends StatefulWidget {
  final String levelId;
  const PhonicsScreen({super.key, required this.levelId});

  @override
  State<PhonicsScreen> createState() => _PhonicsScreenState();
}

class _PhonicsScreenState extends State<PhonicsScreen> {
  List<LetterModel> _letters = [];
  int _currentRound = 0;
  int _score = 0;
  bool _loading = true;
  bool _showReward = false;
  String? _selectedId;
  late LetterModel _targetLetter;
  late List<LetterModel> _choices;

  static const int kTotalRounds = 5;

  @override
  void initState() {
    super.initState();
    _loadLetters();
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

  void _setupRound() {
    if (_letters.length < 4) return;
    _letters.shuffle();
    _targetLetter = _letters.first;
    _choices = _letters.take(4).toList()..shuffle();
    _selectedId = null;

    Future.delayed(const Duration(milliseconds: 300), () {
      final audio = context.read<DodaAudioPlayer>();
      audio.playAsset(_targetLetter.audioFile);
    });
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
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (_loading || _letters.length < 4) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        color: kColorBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top bar
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
                              en: 'Which letter makes this sound?',
                              rw: 'Ni inyuguti iyihe ifite iri jwi?',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text('${_currentRound + 1}/$kTotalRounds'),
                      ],
                    ),
                  ),

                  // Play sound button
                  GestureDetector(
                    onTap: () {
                      context.read<DodaAudioPlayer>().playAsset(_targetLetter.audioFile);
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: kColorPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kColorPrimary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.volume_up, color: Colors.white, size: 56),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Mascot(size: 80, expression: MascotExpression.curious),
                  const SizedBox(height: 24),

                  // Letter choices grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: _choices.map((letter) {
                          final isSelected = _selectedId == letter.id;
                          final isCorrect = letter.id == _targetLetter.id;
                          Color bgColor = kColorSurface;
                          if (isSelected) {
                            bgColor = isCorrect ? kColorSuccess : Colors.red.shade300;
                          } else if (_selectedId != null && isCorrect) {
                            bgColor = kColorSuccess;
                          }

                          return GestureDetector(
                            onTap: () => _onLetterTapped(letter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : kColorTextLight.withOpacity(0.2),
                                  width: 2,
                                ),
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
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : kColorText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
