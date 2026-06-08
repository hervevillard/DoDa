import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../core/audio_player.dart';
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
  final String? svgAsset;
  final Color color;
  final List<String> prerequisites;
  final Widget Function(BuildContext) screenBuilder;

  const LevelNode({
    required this.id,
    required this.titleEn,
    required this.titleRw,
    required this.icon,
    this.svgAsset,
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
    svgAsset: 'assets/images/ui/numbers.svg',
    color: kColorAccent,
    prerequisites: [],
    screenBuilder: (_) => const NumberTracingScreen(levelId: 'numbers'),
  ),
  LevelNode(
    id: 'tracing_1',
    titleEn: 'Letters A-E',
    titleRw: 'Inyuguti A-E',
    icon: Icons.edit_rounded,
    svgAsset: 'assets/images/ui/giraffe.svg',
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
    svgAsset: 'assets/images/ui/zebra.svg',
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
    svgAsset: 'assets/images/ui/kangaroo.svg',
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
    svgAsset: 'assets/images/ui/penguin.svg',
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
    svgAsset: 'assets/images/ui/tiger.svg',
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
    svgAsset: 'assets/images/ui/sounds.svg',
    color: kColorSecondary,
    prerequisites: [],
    screenBuilder: (_) => const PhonicsScreen(levelId: 'phonics_1'),
  ),
  LevelNode(
    id: 'words_1',
    titleEn: 'First Words',
    titleRw: 'Amagambo ya mbere',
    icon: Icons.auto_stories_rounded,
    svgAsset: 'assets/images/ui/First Words.svg',
    color: kColorPrimary,
    prerequisites: [],
    screenBuilder: (_) => const WordBuildingScreen(levelId: 'words_1'),
  ),
];

// Initial scatter positions (as fractions of available area) so bubbles
// start spread out before physics takes over.
const _kInitPositions = [
  (left: 0.06, top: 0.15),
  (left: 0.21, top: 0.55),
  (left: 0.36, top: 0.12),
  (left: 0.50, top: 0.60),
  (left: 0.64, top: 0.10),
  (left: 0.78, top: 0.50),
  (left: 0.88, top: 0.18),
  (left: 0.13, top: 0.72),
];

class ProgressMapScreen extends StatelessWidget {
  const ProgressMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final progress = context.watch<ProgressManager>();
    final audio = context.read<DodaAudioPlayer>();

    return Scaffold(
      body: Stack(
        children: [
          // African savanna gradient background
          Positioned.fill(
            child: AfricanBackground(
              colors: const [
                Color(0xFFFF9A3C),
                Color(0xFFE8611A),
                Color(0xFF1A5C35),
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
                              en: 'What do you want to learn?',
                              rw: 'Urashaka kwiga iki?'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.white, shadows: [
                            const Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(1, 2))
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

                // Physics-based floating bubbles
                Expanded(
                  child: _BubbleField(
                    levels: kLevels,
                    progress: progress,
                    lang: lang,
                    onTap: (level) async {
                      audio.pauseBackground();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: level.screenBuilder),
                      );
                      audio.resumeBackground();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Physics bubble field ──────────────────────────────────────────────────────

const _kBubbleSize = 120.0; // collision radius diameter

class _BubbleState {
  Offset pos;
  Offset vel;
  bool pressed;
  _BubbleState({required this.pos, required this.vel, this.pressed = false});
}

class _BubbleField extends StatefulWidget {
  final List<LevelNode> levels;
  final ProgressManager progress;
  final LanguageProvider lang;
  final void Function(LevelNode) onTap;

  const _BubbleField({
    required this.levels,
    required this.progress,
    required this.lang,
    required this.onTap,
  });

  @override
  State<_BubbleField> createState() => _BubbleFieldState();
}

class _BubbleFieldState extends State<_BubbleField>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Size _fieldSize = Size.zero;
  List<_BubbleState> _bubbles = [];
  bool _initialized = false;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _init(Size size) {
    _fieldSize = size;
    _bubbles = List.generate(widget.levels.length, (i) {
      final pos = _kInitPositions[i % _kInitPositions.length];
      final x = pos.left * (size.width - _kBubbleSize);
      final y = pos.top * (size.height - _kBubbleSize - 20);
      // Random speed 30–70 px/s in a random direction
      final speed = 30.0 + _rng.nextDouble() * 40.0;
      final angle = _rng.nextDouble() * math.pi * 2;
      return _BubbleState(
        pos: Offset(x, y),
        vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
      );
    });
    _initialized = true;
  }

  void _onTick(Duration elapsed) {
    if (!_initialized || _fieldSize == Size.zero) return;
    final dt = _lastTick == Duration.zero
        ? 0.016
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final n = _bubbles.length;
    final r = _kBubbleSize / 2;
    final w = _fieldSize.width;
    final h = _fieldSize.height;

    // Move each bubble
    for (int i = 0; i < n; i++) {
      final b = _bubbles[i];
      b.pos += b.vel * dt;

      // Wall bounce
      if (b.pos.dx < 0) {
        b.pos = Offset(0, b.pos.dy);
        b.vel = Offset(b.vel.dx.abs(), b.vel.dy);
      } else if (b.pos.dx + _kBubbleSize > w) {
        b.pos = Offset(w - _kBubbleSize, b.pos.dy);
        b.vel = Offset(-b.vel.dx.abs(), b.vel.dy);
      }
      if (b.pos.dy < 0) {
        b.pos = Offset(b.pos.dx, 0);
        b.vel = Offset(b.vel.dx, b.vel.dy.abs());
      } else if (b.pos.dy + _kBubbleSize > h) {
        b.pos = Offset(b.pos.dx, h - _kBubbleSize);
        b.vel = Offset(b.vel.dx, -b.vel.dy.abs());
      }
    }

    // Collision detection — O(n²) fine for ≤8 bubbles
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        final ci = _bubbles[i].pos + Offset(r, r);
        final cj = _bubbles[j].pos + Offset(r, r);
        final delta = cj - ci;
        final dist = delta.distance;
        if (dist < _kBubbleSize && dist > 0) {
          // Separate overlapping bubbles
          final overlap = _kBubbleSize - dist;
          final norm = delta / dist;
          _bubbles[i].pos -= norm * (overlap / 2);
          _bubbles[j].pos += norm * (overlap / 2);

          // Exchange velocity along collision axis
          final relVel = _bubbles[i].vel - _bubbles[j].vel;
          final dot = relVel.dx * norm.dx + relVel.dy * norm.dy;
          if (dot > 0) {
            final impulse = norm * dot;
            _bubbles[i].vel -= impulse;
            _bubbles[j].vel += impulse;
          }
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      if (!_initialized || _fieldSize != size) _init(size);

      return Stack(
        children: List.generate(_bubbles.length, (i) {
          final b = _bubbles[i];
          final level = widget.levels[i];
          return Positioned(
            left: b.pos.dx,
            top: b.pos.dy,
            child: _LevelBubble(
              level: level,
              isCompleted: widget.progress.isLevelCompleted(level.id),
              stars: widget.progress.starsForLevel(level.id),
              lang: widget.lang,
              pressed: b.pressed,
              onPressChanged: (v) => setState(() => b.pressed = v),
              onTap: () => widget.onTap(level),
            ),
          );
        }),
      );
    });
  }
}

// ── Level bubble ──────────────────────────────────────────────────────────────

enum _BubbleShape { circle, square, star }

_BubbleShape _shapeFor(String levelId) {
  if (levelId == 'phonics_1') return _BubbleShape.square;
  if (levelId == 'words_1') return _BubbleShape.star;
  return _BubbleShape.circle;
}

class _LevelBubble extends StatelessWidget {
  final LevelNode level;
  final bool isCompleted;
  final int stars;
  final LanguageProvider lang;
  final bool pressed;
  final ValueChanged<bool> onPressChanged;
  final VoidCallback onTap;

  const _LevelBubble({
    required this.level,
    required this.isCompleted,
    required this.stars,
    required this.lang,
    required this.pressed,
    required this.onPressChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = lang.localizedText(en: level.titleEn, rw: level.titleRw);
    final shape = _shapeFor(level.id);

    return GestureDetector(
      onTapDown: (_) => onPressChanged(true),
      onTapUp: (_) {
        onPressChanged(false);
        onTap();
      },
      onTapCancel: () => onPressChanged(false),
      child: AnimatedScale(
        scale: pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: _kBubbleSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BadgeShape(
                shape: shape,
                color: level.color,
                size: _kBubbleSize - 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BubbleIcon(
                      svgAsset: level.svgAsset,
                      fallbackIcon: level.icon,
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          3,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < stars ? kColorStar : Colors.white30,
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
                  color: Colors.black38,
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
      ),
    );
  }
}

// ── Bubble icon (SVG with white contour ring, falls back to IconData) ─────────

class _BubbleIcon extends StatelessWidget {
  final String? svgAsset;
  final IconData fallbackIcon;

  const _BubbleIcon({required this.svgAsset, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    if (svgAsset == null) {
      return Icon(fallbackIcon, color: Colors.white, size: 34);
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        color: Colors.white12,
      ),
      padding: const EdgeInsets.all(7),
      child: SvgPicture.asset(
        svgAsset!,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        fit: BoxFit.contain,
      ),
    );
  }
}

// ── Badge shape wrapper ───────────────────────────────────────────────────────

class _BadgeShape extends StatelessWidget {
  final _BubbleShape shape;
  final Color color;
  final double size;
  final Widget child;

  const _BadgeShape({
    required this.shape,
    required this.color,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (shape) {
      case _BubbleShape.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 22,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(child: child),
        );
      case _BubbleShape.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 22,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(child: child),
        );
      case _BubbleShape.star:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _StarPainter(color: color),
            child: Center(child: child),
          ),
        );
    }
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  const _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.42;
    const points = 5;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = math.pi / points * i - math.pi / 2;
      final r = i.isEven ? outerR : innerR;
      final pt = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    // Glow shadow
    canvas.drawShadow(path, color.withOpacity(0.5), 12, false);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
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

    _drawAcacia(canvas, size, 0.2, 0.28);
    _drawAcacia(canvas, size, 0.7, 0.15);
  }

  void _drawAcacia(Canvas canvas, Size size, double xFrac, double topFrac) {
    final x = size.width * xFrac;
    final top = size.height * topFrac;
    final paint = Paint()..color = const Color(0xFF0A2E15).withOpacity(0.75);

    canvas.drawRect(Rect.fromLTWH(x - 3, top + 20, 6, 40), paint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x, top + 14), width: 50, height: 22),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

