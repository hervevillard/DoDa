import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../theme.dart';
import '../widgets/language_toggle.dart';
import '../widgets/star_counter.dart';
import 'letter_tracing_screen.dart';
import 'phonics_screen.dart';
import 'word_building_screen.dart';

class LevelNode {
  final String id;
  final String titleEn;
  final String titleRw;
  final IconData icon;
  final Color color;
  final List<String> prerequisites;
  final Widget Function(BuildContext) screenBuilder;

  const LevelNode({
    required this.id,
    required this.titleEn,
    required this.titleRw,
    required this.icon,
    required this.color,
    required this.prerequisites,
    required this.screenBuilder,
  });
}

final List<LevelNode> kLevels = [
  LevelNode(
    id: 'tracing_1',
    titleEn: 'Letters A-E',
    titleRw: 'Inyuguti A-E',
    icon: Icons.edit,
    color: const Color(0xFF6BCB77),
    prerequisites: [],
    screenBuilder: (_) => const LetterTracingScreen(levelId: 'tracing_1', startLetter: 0, endLetter: 4),
  ),
  LevelNode(
    id: 'phonics_1',
    titleEn: 'Sounds A-E',
    titleRw: 'Amajwi A-E',
    icon: Icons.volume_up,
    color: const Color(0xFF4ECDC4),
    prerequisites: ['tracing_1'],
    screenBuilder: (_) => const PhonicsScreen(levelId: 'phonics_1'),
  ),
  LevelNode(
    id: 'words_1',
    titleEn: 'First Words',
    titleRw: 'Amagambo ya mbere',
    icon: Icons.abc,
    color: const Color(0xFFFF6B35),
    prerequisites: ['phonics_1'],
    screenBuilder: (_) => const WordBuildingScreen(levelId: 'words_1'),
  ),
  LevelNode(
    id: 'tracing_2',
    titleEn: 'Letters F-J',
    titleRw: 'Inyuguti F-J',
    icon: Icons.edit,
    color: const Color(0xFF6BCB77),
    prerequisites: ['words_1'],
    screenBuilder: (_) => const LetterTracingScreen(levelId: 'tracing_2', startLetter: 5, endLetter: 9),
  ),
  LevelNode(
    id: 'phonics_2',
    titleEn: 'Sounds F-J',
    titleRw: 'Amajwi F-J',
    icon: Icons.volume_up,
    color: const Color(0xFF4ECDC4),
    prerequisites: ['tracing_2'],
    screenBuilder: (_) => const PhonicsScreen(levelId: 'phonics_2'),
  ),
];

class ProgressMapScreen extends StatelessWidget {
  const ProgressMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final progress = context.watch<ProgressManager>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4F1F9), Color(0xFFB8E4C9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 28, color: kColorText),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        lang.localizedText(en: 'Learning Path', rw: 'Inzira y\'Kwiga'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const StarCounter(),
                    const SizedBox(width: 8),
                    const LanguageToggle(),
                  ],
                ),
              ),

              // Level map
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildPathLayout(context, lang, progress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathLayout(
    BuildContext context,
    LanguageProvider lang,
    ProgressManager progress,
  ) {
    return Column(
      children: kLevels.asMap().entries.map((entry) {
        final index = entry.key;
        final level = entry.value;
        final isUnlocked = progress.isLevelUnlocked(level.id, level.prerequisites);
        final isCompleted = progress.isLevelCompleted(level.id);
        final stars = progress.starsForLevel(level.id);
        final isLeft = index.isEven;

        return Column(
          children: [
            if (index > 0)
              _PathConnector(isLeft: isLeft),
            _LevelBubble(
              level: level,
              isUnlocked: isUnlocked,
              isCompleted: isCompleted,
              stars: stars,
              isLeft: isLeft,
              lang: lang,
              onTap: isUnlocked
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: level.screenBuilder),
                      )
                  : null,
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _PathConnector extends StatelessWidget {
  final bool isLeft;
  const _PathConnector({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: CustomPaint(
        painter: _DashedLinePainter(isLeft: isLeft),
        size: const Size(double.infinity, 48),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final bool isLeft;
  _DashedLinePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final startX = isLeft ? size.width * 0.5 : size.width * 0.5;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX, (y + 10).clamp(0, size.height)),
        paint,
      );
      y += 18;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LevelBubble extends StatelessWidget {
  final LevelNode level;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final bool isLeft;
  final LanguageProvider lang;
  final VoidCallback? onTap;

  const _LevelBubble({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    required this.isLeft,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked ? level.color : kColorLocked;
    final title = lang.localizedText(en: level.titleEn, rw: level.titleRw);

    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnlocked ? level.icon : Icons.lock,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      Icons.star,
                      size: 18,
                      color: i < stars ? kColorStar : Colors.white38,
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
