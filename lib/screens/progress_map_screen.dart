import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../theme.dart';
import '../widgets/language_toggle.dart';
import '../widgets/star_counter.dart';
import '../widgets/african_decoration.dart';
import 'letter_tracing_screen.dart';
import 'phonics_screen.dart';
import 'word_building_screen.dart';
import 'number_tracing_screen.dart';

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
    id: 'numbers',
    titleEn: 'Numbers 0-9',
    titleRw: 'Imibare 0-9',
    icon: Icons.tag_rounded,
    color: kColorAccent,
    prerequisites: [],
    screenBuilder: (_) => const NumberTracingScreen(levelId: 'numbers'),
  ),
  LevelNode(
    id: 'tracing_1',
    titleEn: 'Letters A-E',
    titleRw: 'Inyuguti A-E',
    icon: Icons.edit_rounded,
    color: kColorKente1,
    prerequisites: [],
    screenBuilder: (_) =>
        const LetterTracingScreen(levelId: 'tracing_1', startLetter: 0, endLetter: 4),
  ),
  LevelNode(
    id: 'tracing_2',
    titleEn: 'Letters F-J',
    titleRw: 'Inyuguti F-J',
    icon: Icons.edit_rounded,
    color: kColorKente1,
    prerequisites: [],
    screenBuilder: (_) =>
        const LetterTracingScreen(levelId: 'tracing_2', startLetter: 5, endLetter: 9),
  ),
  LevelNode(
    id: 'tracing_3',
    titleEn: 'Letters K-O',
    titleRw: 'Inyuguti K-O',
    icon: Icons.edit_rounded,
    color: kColorKente1,
    prerequisites: [],
    screenBuilder: (_) =>
        const LetterTracingScreen(levelId: 'tracing_3', startLetter: 10, endLetter: 14),
  ),
  LevelNode(
    id: 'tracing_4',
    titleEn: 'Letters P-T',
    titleRw: 'Inyuguti P-T',
    icon: Icons.edit_rounded,
    color: kColorKente1,
    prerequisites: [],
    screenBuilder: (_) =>
        const LetterTracingScreen(levelId: 'tracing_4', startLetter: 15, endLetter: 19),
  ),
  LevelNode(
    id: 'tracing_5',
    titleEn: 'Letters U-Z',
    titleRw: 'Inyuguti U-Z',
    icon: Icons.edit_rounded,
    color: kColorKente1,
    prerequisites: [],
    screenBuilder: (_) =>
        const LetterTracingScreen(levelId: 'tracing_5', startLetter: 20, endLetter: 25),
  ),
  LevelNode(
    id: 'phonics_1',
    titleEn: 'Sounds',
    titleRw: 'Amajwi',
    icon: Icons.music_note_rounded,
    color: kColorSecondary,
    prerequisites: [],
    screenBuilder: (_) => const PhonicsScreen(levelId: 'phonics_1'),
  ),
  LevelNode(
    id: 'words_1',
    titleEn: 'First Words',
    titleRw: 'Amagambo ya mbere',
    icon: Icons.auto_stories_rounded,
    color: kColorPrimary,
    prerequisites: [],
    screenBuilder: (_) => const WordBuildingScreen(levelId: 'words_1'),
  ),
];

class ProgressMapScreen extends StatelessWidget {
  const ProgressMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final progress = context.watch<ProgressManager>();

    return Scaffold(
      body: Stack(
        children: [
          // African savanna gradient background
          Positioned.fill(
            child: AfricanBackground(
              colors: const [
                Color(0xFFFF9A3C), // sunrise amber
                Color(0xFFE8611A), // terracotta mid
                Color(0xFF1A5C35), // deep savanna green
              ],
              child: const SizedBox.expand(),
            ),
          ),

          // Decorative sun top-right
          const Positioned(
            top: -20,
            right: -20,
            child: DecorativeSun(size: 160),
          ),

          // Faint silhouette hills at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _HillsPainter(),
              size: const Size(double.infinity, 80),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      _BackButton(onTap: () => Navigator.pop(context)),
                      Expanded(
                        child: Text(
                          lang.localizedText(
                              en: 'Learning Path', rw: 'Inzira y\'Kwiga'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.white, shadows: [
                            Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(1, 2))
                          ]),
                        ),
                      ),
                      const StarCounter(),
                      const SizedBox(width: 8),
                      const LanguageToggle(),
                    ],
                  ),
                ),

                // Kente strip
                const KenteDivider(height: 10),
                const SizedBox(height: 4),

                // Level map — horizontal scroll for landscape
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: _buildHorizontalPath(context, lang, progress),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPath(
    BuildContext context,
    LanguageProvider lang,
    ProgressManager progress,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: kLevels.asMap().entries.expand((entry) {
        final index = entry.key;
        final level = entry.value;
        final isCompleted = progress.isLevelCompleted(level.id);
        final stars = progress.starsForLevel(level.id);

        return [
          if (index > 0) const _PathSegment(),
          _LevelBubble(
            level: level,
            isCompleted: isCompleted,
            stars: stars,
            floatOffset: index * 0.4,
            lang: lang,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: level.screenBuilder),
            ),
          ),
        ];
      }).toList(),
    );
  }
}

// ── Path segment connector ────────────────────────────────────────────────────

class _PathSegment extends StatelessWidget {
  const _PathSegment();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: CustomPaint(
        painter: _DottedLinePainter(),
        size: const Size(60, 12),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kColorAccent.withOpacity(0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dotSpacing = 10.0;
    double x = 0;
    final y = size.height / 2;
    while (x <= size.width) {
      canvas.drawCircle(Offset(x, y), 3, paint);
      x += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Level bubble ──────────────────────────────────────────────────────────────

class _LevelBubble extends StatefulWidget {
  final LevelNode level;
  final bool isCompleted;
  final int stars;
  final double floatOffset;
  final LanguageProvider lang;
  final VoidCallback onTap;

  const _LevelBubble({
    required this.level,
    required this.isCompleted,
    required this.stars,
    required this.floatOffset,
    required this.lang,
    required this.onTap,
  });

  @override
  State<_LevelBubble> createState() => _LevelBubbleState();
}

class _LevelBubbleState extends State<_LevelBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Each bubble starts at a different phase so they don't all move in sync
    _floatCtrl.value = (widget.floatOffset % 1.0);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.lang.localizedText(en: widget.level.titleEn, rw: widget.level.titleRw);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdinkraBadge(
              color: widget.level.color,
              size: 110,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.level.icon, color: Colors.white, size: 34),
                  if (widget.isCompleted) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: i < widget.stars ? kColorStar : Colors.white30,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back_ios_new,
            size: 24, color: Colors.white),
      ),
    );
  }
}

// ── Hills silhouette ──────────────────────────────────────────────────────────

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F3D20).withOpacity(0.6);
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.15, 0, size.width * 0.28, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.40, size.height * 0.55, size.width * 0.5, size.height * 0.2)
      ..quadraticBezierTo(
          size.width * 0.62, -size.height * 0.1, size.width * 0.75, size.height * 0.35)
      ..quadraticBezierTo(
          size.width * 0.88, size.height * 0.6, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    // Acacia tree silhouettes
    _drawAcacia(canvas, size, 0.2, 0.28);
    _drawAcacia(canvas, size, 0.7, 0.15);
  }

  void _drawAcacia(Canvas canvas, Size size, double xFrac, double topFrac) {
    final x = size.width * xFrac;
    final top = size.height * topFrac;
    final paint = Paint()..color = const Color(0xFF0A2E15).withOpacity(0.75);

    // Trunk
    canvas.drawRect(Rect.fromLTWH(x - 3, top + 20, 6, 40), paint);

    // Canopy (flat-topped oval)
    canvas.drawOval(Rect.fromCenter(center: Offset(x, top + 14), width: 50, height: 22), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
