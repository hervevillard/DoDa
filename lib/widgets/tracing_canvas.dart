import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/letter_model.dart';
import '../theme.dart';
import 'african_decoration.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State enum
// ─────────────────────────────────────────────────────────────────────────────

enum _TracingMode { watching, practicing }

// ─────────────────────────────────────────────────────────────────────────────
// TracingCanvas — public widget
// ─────────────────────────────────────────────────────────────────────────────

class TracingCanvas extends StatefulWidget {
  final LetterModel letter;
  final void Function(double accuracy) onComplete;

  const TracingCanvas({
    super.key,
    required this.letter,
    required this.onComplete,
  });

  @override
  State<TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends State<TracingCanvas>
    with TickerProviderStateMixin {

  // Guide paths (normalised 0–1)
  List<List<Offset>> _guidePaths = [];

  // Demo state
  _TracingMode _mode = _TracingMode.watching;
  late AnimationController _demoController;
  int _demoStrokeIndex = 0;

  // Practice state
  final List<List<Offset>> _drawnStrokes = [];
  List<Offset> _currentStroke = [];
  int _activeStrokeIndex = 0;
  bool _completed = false;
  Color _penColor = kTracingColors[0];
  Offset? _cursorPos;
  bool _isDrawing = false;

  // Visual animations
  late AnimationController _glowController;
  late AnimationController _pulseController;

  Size _lastCanvasSize = Size.zero;
  final _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _guidePaths = _parseStrokePaths(widget.letter.strokePaths);

    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    // Each stroke demo lasts 1.8 s
    _demoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _demoController.addStatusListener(_onDemoStatus);

    // Auto-play demo after a short pause so the child can see the letter first
    Future.delayed(const Duration(milliseconds: 700), _startDemo);
  }

  @override
  void didUpdateWidget(TracingCanvas old) {
    super.didUpdateWidget(old);
    if (old.letter.id != widget.letter.id) {
      _guidePaths = _parseStrokePaths(widget.letter.strokePaths);
      _resetAll();
      Future.delayed(const Duration(milliseconds: 400), _startDemo);
    }
  }

  @override
  void dispose() {
    _demoController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Demo sequencing ───────────────────────────────────────────────────────────

  void _startDemo() {
    if (!mounted) return;
    setState(() {
      _mode = _TracingMode.watching;
      _demoStrokeIndex = 0;
    });
    if (_guidePaths.isEmpty) {
      // No paths defined yet — jump straight to practice
      setState(() => _mode = _TracingMode.practicing);
      return;
    }
    _demoController.reset();
    _demoController.forward();
  }

  void _onDemoStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final next = _demoStrokeIndex + 1;
    if (next < _guidePaths.length) {
      setState(() => _demoStrokeIndex = next);
      _demoController.reset();
      _demoController.forward();
    } else {
      // All strokes demoed — brief pause then hand over to child
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _mode = _TracingMode.practicing);
      });
    }
  }

  // ── SVG path parser ───────────────────────────────────────────────────────────

  List<List<Offset>> _parseStrokePaths(List<String> svgPaths) {
    return svgPaths.map((path) {
      final pts = <Offset>[];
      final cmds = path.trim().split(RegExp(r'(?=[MLQCmlqc])'));
      Offset cur = Offset.zero;

      for (final cmd in cmds) {
        if (cmd.isEmpty) continue;
        final type = cmd[0].toUpperCase();
        final nums = _extractNumbers(cmd.substring(1));

        switch (type) {
          case 'M':
            if (nums.length >= 2) {
              cur = Offset(nums[0] / 100, nums[1] / 100);
              pts.add(cur);
            }
          case 'L':
            for (int i = 0; i + 1 < nums.length; i += 2) {
              cur = Offset(nums[i] / 100, nums[i + 1] / 100);
              pts.add(cur);
            }
          case 'Q':
            if (nums.length >= 4) {
              final cp = Offset(nums[0] / 100, nums[1] / 100);
              final end = Offset(nums[2] / 100, nums[3] / 100);
              pts.addAll(_bezier2(cur, cp, end));
              cur = end;
            }
          case 'C':
            if (nums.length >= 6) {
              final cp1 = Offset(nums[0] / 100, nums[1] / 100);
              final cp2 = Offset(nums[2] / 100, nums[3] / 100);
              final end = Offset(nums[4] / 100, nums[5] / 100);
              pts.addAll(_bezier3(cur, cp1, cp2, end));
              cur = end;
            }
        }
      }
      return pts;
    }).toList();
  }

  List<double> _extractNumbers(String s) =>
      RegExp(r'-?[\d.]+')
          .allMatches(s)
          .map((m) => double.parse(m.group(0)!))
          .toList();

  List<Offset> _bezier2(Offset p0, Offset p1, Offset p2, {int steps = 20}) =>
      List.generate(steps + 1, (i) {
        final t = i / steps, mt = 1 - t;
        return Offset(
          mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
          mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
        );
      });

  List<Offset> _bezier3(Offset p0, Offset p1, Offset p2, Offset p3,
      {int steps = 24}) =>
      List.generate(steps + 1, (i) {
        final t = i / steps, mt = 1 - t;
        return Offset(
          mt * mt * mt * p0.dx + 3 * mt * mt * t * p1.dx +
              3 * mt * t * t * p2.dx + t * t * t * p3.dx,
          mt * mt * mt * p0.dy + 3 * mt * mt * t * p1.dy +
              3 * mt * t * t * p2.dy + t * t * t * p3.dy,
        );
      });

  // ── Gesture handling (practice only) ─────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    if (_completed || _mode != _TracingMode.practicing) return;
    setState(() {
      _isDrawing = true;
      _cursorPos = _localPos(d.globalPosition);
      _currentStroke = [_cursorPos!];
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_completed || _mode != _TracingMode.practicing) return;
    final pos = _localPos(d.globalPosition);
    setState(() {
      _cursorPos = pos;
      _currentStroke.add(pos);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_completed || _currentStroke.isEmpty || _mode != _TracingMode.practicing)
      return;
    setState(() {
      _isDrawing = false;
      _drawnStrokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
    _evaluateStroke();
  }

  Offset _localPos(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.globalToLocal(global) ?? global;
  }

  // ── Accuracy ──────────────────────────────────────────────────────────────────

  void _evaluateStroke() {
    if (_guidePaths.isEmpty) return;
    final accuracy = _calculateCoverage();
    if (_activeStrokeIndex < _guidePaths.length - 1 &&
        _strokeCoverage(_activeStrokeIndex) > 0.4) {
      setState(() => _activeStrokeIndex++);
    }
    if (_drawnStrokes.length >= _guidePaths.length && accuracy > 0.25) {
      setState(() => _completed = true);
      widget.onComplete(accuracy);
    }
  }

  double _calculateCoverage() {
    if (_guidePaths.isEmpty || _drawnStrokes.isEmpty) return 0;
    double total = 0;
    for (int i = 0; i < _guidePaths.length; i++) total += _strokeCoverage(i);
    return (total / _guidePaths.length).clamp(0.0, 1.0);
  }

  double _strokeCoverage(int idx) {
    if (idx >= _guidePaths.length || _lastCanvasSize == Size.zero) return 0;
    final guide = _guidePaths[idx];
    if (guide.isEmpty) return 0;
    final userPts =
        idx < _drawnStrokes.length ? _drawnStrokes[idx] : _currentStroke;
    if (userPts.isEmpty) return 0;
    int hits = 0;
    for (final gpt in guide) {
      final gs = Offset(
          gpt.dx * _lastCanvasSize.width, gpt.dy * _lastCanvasSize.height);
      final nearest = userPts.fold<double>(
          double.infinity, (b, p) => math.min(b, (p - gs).distance));
      if (nearest < 36) hits++;
    }
    return hits / guide.length;
  }

  void _resetAll() {
    setState(() {
      _drawnStrokes.clear();
      _currentStroke = [];
      _activeStrokeIndex = 0;
      _completed = false;
      _cursorPos = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Banner ────────────────────────────────────────────────────────────
        _ModeBanner(mode: _mode, onWatchAgain: _startDemo),
        const SizedBox(height: 8),

        // ── Color picker (practice only) ──────────────────────────────────────
        if (_mode == _TracingMode.practicing) ...[
          _ColorPicker(
            selected: _penColor,
            onSelect: (c) => setState(() => _penColor = c),
          ),
          const SizedBox(height: 8),
        ],

        // ── Canvas ────────────────────────────────────────────────────────────
        Expanded(
          child: LayoutBuilder(builder: (ctx, constraints) {
            _lastCanvasSize =
                Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              key: _canvasKey,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: kColorEarth.withOpacity(0.25), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                        color: kColorEarth.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_glowController, _pulseController, _demoController]),
                    builder: (_, __) => CustomPaint(
                      size: Size(
                          constraints.maxWidth, constraints.maxHeight),
                      painter: _TracingPainter(
                        letter: widget.letter.letter,
                        guidePaths: _guidePaths,
                        mode: _mode,
                        demoStrokeIndex: _demoStrokeIndex,
                        demoProgress: _demoController.value,
                        drawnStrokes: List.from(_drawnStrokes),
                        currentStroke: List.from(_currentStroke),
                        activeStrokeIndex: _activeStrokeIndex,
                        penColor: _penColor,
                        glowValue: _glowController.value,
                        pulseValue: _pulseController.value,
                        cursorPos: _cursorPos,
                        isDrawing: _isDrawing,
                        completed: _completed,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        // ── Practice bottom controls ───────────────────────────────────────────
        if (_mode == _TracingMode.practicing && !_completed)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(_guidePaths.length, (i) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _drawnStrokes.length
                          ? kColorSuccess
                          : i == _activeStrokeIndex
                              ? kColorPrimary
                              : kColorSand,
                    ),
                  )),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _resetAll,
                icon: const Icon(Icons.refresh, color: kColorTextLight, size: 18),
                label: const Text('Try again',
                    style:
                        TextStyle(color: kColorTextLight, fontSize: 13)),
              ),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode banner
// ─────────────────────────────────────────────────────────────────────────────

class _ModeBanner extends StatelessWidget {
  final _TracingMode mode;
  final VoidCallback onWatchAgain;
  const _ModeBanner({required this.mode, required this.onWatchAgain});

  @override
  Widget build(BuildContext context) {
    if (mode == _TracingMode.watching) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kColorSecondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kColorSecondary.withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye_rounded,
                color: kColorSecondary, size: 20),
            SizedBox(width: 8),
            Text('Watch how to draw it!',
                style: TextStyle(
                    color: kColorSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kColorPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kColorPrimary.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, color: kColorPrimary, size: 20),
              SizedBox(width: 8),
              Text('Your turn! Trace the letter',
                  style: TextStyle(
                      color: kColorPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        TextButton.icon(
          onPressed: onWatchAgain,
          icon: const Icon(Icons.replay_rounded,
              color: kColorTextLight, size: 18),
          label: const Text('Watch again',
              style: TextStyle(color: kColorTextLight, fontSize: 13)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color picker
// ─────────────────────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final Color selected;
  final void Function(Color) onSelect;
  const _ColorPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: kTracingColors.map((c) {
        final active = c == selected;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 36 : 28,
            height: active ? 36 : 28,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              border: Border.all(
                  color: active ? Colors.white : Colors.transparent, width: 3),
              boxShadow: active
                  ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

class _TracingPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> guidePaths;
  final _TracingMode mode;
  final int demoStrokeIndex;
  final double demoProgress;
  final List<List<Offset>> drawnStrokes;
  final List<Offset> currentStroke;
  final int activeStrokeIndex;
  final Color penColor;
  final double glowValue;
  final double pulseValue;
  final Offset? cursorPos;
  final bool isDrawing;
  final bool completed;

  const _TracingPainter({
    required this.letter,
    required this.guidePaths,
    required this.mode,
    required this.demoStrokeIndex,
    required this.demoProgress,
    required this.drawnStrokes,
    required this.currentStroke,
    required this.activeStrokeIndex,
    required this.penColor,
    required this.glowValue,
    required this.pulseValue,
    required this.cursorPos,
    required this.isDrawing,
    required this.completed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ruled background lines
    _drawRuledLines(canvas, size);

    // 2. Large ghost letter
    _drawGhostLetter(canvas, size);

    // 3. Guide stroke paths (always visible)
    _drawGuidePaths(canvas, size);

    if (mode == _TracingMode.watching) {
      // 4a. Demo trail (ink already drawn by hand)
      _drawDemoTrail(canvas, size);
      // 4b. Animated pencil hand
      _drawDemoHand(canvas, size);
    } else {
      // 4c. User's completed strokes
      for (final stroke in drawnStrokes) {
        _drawUserStroke(canvas, stroke, completed);
      }
      // 4d. Current in-progress stroke
      if (currentStroke.isNotEmpty) {
        _drawUserStroke(canvas, currentStroke, false);
      }
      // 4e. Cursor
      if (cursorPos != null) _drawCursor(canvas, cursorPos!);
      // 4f. Pulsing start hint on active stroke
      if (!completed) _drawStartHint(canvas, size);
    }

    // 5. Completion sparkles
    if (completed) _drawCompletionSparkles(canvas, size);
  }

  // ── Ruled lines ───────────────────────────────────────────────────────────────

  void _drawRuledLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kColorSand.withOpacity(0.5)
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final y = size.height / 4 * i;
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), paint);
    }
    // Mid baseline slightly stronger
    paint.color = kColorEarth.withOpacity(0.15);
    canvas.drawLine(
        Offset(8, size.height / 2), Offset(size.width - 8, size.height / 2), paint);
  }

  // ── Ghost letter ──────────────────────────────────────────────────────────────

  void _drawGhostLetter(Canvas canvas, Size size) {
    // In watching mode show it slightly more clearly
    final opacity = mode == _TracingMode.watching
        ? 0.22 + 0.06 * glowValue
        : completed
            ? 0.08
            : 0.18;

    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.nunito(
          fontSize: size.height * 0.78,
          fontWeight: FontWeight.w900,
          color: kColorEarth.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width);
    tp.paint(canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  // ── Guide stroke paths (dashed) ───────────────────────────────────────────────

  void _drawGuidePaths(Canvas canvas, Size size) {
    for (int i = 0; i < guidePaths.length; i++) {
      final pts = _toScreen(guidePaths[i], size);
      if (pts.length < 2) continue;

      final isDone = i < drawnStrokes.length ||
          (mode == _TracingMode.watching && i < demoStrokeIndex);
      final isActive =
          mode == _TracingMode.practicing && i == activeStrokeIndex;

      final color = isDone
          ? kColorSuccess.withOpacity(0.35)
          : isActive
              ? Color.lerp(kColorPrimary.withOpacity(0.5),
                  kColorAccent.withOpacity(0.75), glowValue)!
              : kColorTextLight.withOpacity(0.22);

      _drawDashed(canvas, pts,
          Paint()
            ..color = color
            ..strokeWidth = isActive ? 6 : 4
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
          dashLen: 9,
          gapLen: 6);

      // Numbered start circle on each stroke
      _drawStrokeNumber(canvas, pts.first, i, isDone);
    }
  }

  void _drawStrokeNumber(Canvas canvas, Offset pos, int index, bool done) {
    final r = 13.0;
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = (done ? kColorSuccess : kColorPrimary).withOpacity(0.85),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '${index + 1}',
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  // ── Demo trail ────────────────────────────────────────────────────────────────

  void _drawDemoTrail(Canvas canvas, Size size) {
    // Completed strokes in this demo run
    for (int i = 0; i < demoStrokeIndex; i++) {
      if (i >= guidePaths.length) break;
      final pts = _toScreen(guidePaths[i], size);
      if (pts.length < 2) continue;
      _drawSmooth(canvas, pts, kColorPrimary.withOpacity(0.55), 18);
    }

    // Current stroke up to demoProgress
    if (demoStrokeIndex < guidePaths.length) {
      final pts = _toScreen(guidePaths[demoStrokeIndex], size);
      if (pts.length >= 2) {
        final path = _pointsToPath(pts);
        final metrics = path.computeMetrics().toList();
        if (metrics.isNotEmpty) {
          final metric = metrics.first;
          final dist = (demoProgress * metric.length).clamp(0.0, metric.length);
          if (dist > 0) {
            final trailPath = metric.extractPath(0, dist);
            canvas.drawPath(
              trailPath,
              Paint()
                ..color = kColorPrimary.withOpacity(0.65)
                ..strokeWidth = 18
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..style = PaintingStyle.stroke,
            );
          }
        }
      }
    }
  }

  // ── Animated pencil hand ──────────────────────────────────────────────────────

  void _drawDemoHand(Canvas canvas, Size size) {
    if (demoStrokeIndex >= guidePaths.length) return;
    final pts = _toScreen(guidePaths[demoStrokeIndex], size);
    if (pts.length < 2) return;

    final path = _pointsToPath(pts);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final dist = (demoProgress * metric.length).clamp(0.0, metric.length);
    final tangent = metric.getTangentForOffset(dist);
    if (tangent == null) return;

    _drawPencil(canvas, tangent.position, tangent.angle);
  }

  void _drawPencil(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Rotate so pencil tip points in direction of travel
    canvas.rotate(angle + math.pi / 2);

    // --- Pencil body ---

    // Tip (graphite point)
    canvas.drawPath(
      Path()
        ..moveTo(0, -28)
        ..lineTo(-5, -14)
        ..lineTo(5, -14)
        ..close(),
      Paint()..color = const Color(0xFF3A2010),
    );

    // Wood under tip
    canvas.drawPath(
      Path()
        ..moveTo(0, -22)
        ..lineTo(-5, -14)
        ..lineTo(5, -14)
        ..close(),
      Paint()..color = const Color(0xFFD4A070),
    );

    // Yellow body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 2), width: 12, height: 30),
        const Radius.circular(2),
      ),
      Paint()..color = kColorAccent,
    );

    // Ferrule (silver band)
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 18), width: 12, height: 5),
      Paint()..color = const Color(0xFFBDC3C7),
    );

    // Eraser
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 24), width: 12, height: 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFB3C1),
    );

    // --- Hand grip ---
    // Palm (rounded rectangle behind the pencil)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-18, 22, 36, 32),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFFD4956A),
    );

    // Three finger bumps
    for (int i = -1; i <= 1; i++) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(i * 10.0, 18), width: 13, height: 10),
        Paint()..color = const Color(0xFFD4956A),
      );
    }

    // Knuckle lines
    final knucklePaint = Paint()
      ..color = const Color(0xFFAA7050).withOpacity(0.5)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = -1; i <= 1; i++) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(i * 10.0, 26), width: 10, height: 7),
        math.pi, math.pi, false, knucklePaint,
      );
    }

    canvas.restore();

    // Ink dot at pencil tip
    canvas.drawCircle(
      pos,
      4,
      Paint()..color = kColorPrimary.withOpacity(0.8),
    );
  }

  // ── User stroke ───────────────────────────────────────────────────────────────

  void _drawUserStroke(Canvas canvas, List<Offset> pts, bool done) {
    if (pts.length < 2) return;
    _drawSmooth(canvas, pts, done ? kColorSuccess : penColor, 20);
  }

  void _drawSmooth(Canvas canvas, List<Offset> pts, Color color, double width) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length - 1; i++) {
      final mid = Offset(
          (pts[i].dx + pts[i + 1].dx) / 2, (pts[i].dy + pts[i + 1].dy) / 2);
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke);
  }

  // ── Cursor ────────────────────────────────────────────────────────────────────

  void _drawCursor(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos, 26,
        Paint()
          ..color = penColor.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(pos, 5, Paint()..color = penColor);
  }

  // ── Pulsing start hint ────────────────────────────────────────────────────────

  void _drawStartHint(Canvas canvas, Size size) {
    if (activeStrokeIndex >= guidePaths.length) return;
    final pts = _toScreen(guidePaths[activeStrokeIndex], size);
    if (pts.isEmpty) return;
    final r = 16 + 4 * pulseValue;
    canvas.drawCircle(
        pts.first,
        r + 8,
        Paint()
          ..color = kColorPrimary.withOpacity(0.25 * (1 - pulseValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
  }

  // ── Completion sparkles ───────────────────────────────────────────────────────

  void _drawCompletionSparkles(Canvas canvas, Size size) {
    final paint = Paint()..color = kColorStar.withOpacity(0.9);
    _drawStar(canvas, Offset(size.width * 0.85, size.height * 0.12), 14, paint);
    _drawStar(canvas, Offset(size.width * 0.12, size.height * 0.10), 9, paint);
    _drawStar(canvas, Offset(size.width * 0.90, size.height * 0.85), 11, paint);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final a = math.pi / 5 * i - math.pi / 2;
      final rad = i.isEven ? r : r * 0.4;
      final pt = Offset(c.dx + rad * math.cos(a), c.dy + rad * math.sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  List<Offset> _toScreen(List<Offset> pts, Size size) =>
      pts.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

  Path _pointsToPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }

  void _drawDashed(Canvas canvas, List<Offset> pts, Paint paint,
      {double dashLen = 9, double gapLen = 6}) {
    final path = _pointsToPath(pts);
    bool gap = false;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end =
            math.min(dist + (gap ? gapLen : dashLen), metric.length);
        if (!gap) canvas.drawPath(metric.extractPath(dist, end), paint);
        dist = end;
        gap = !gap;
      }
    }
  }

  @override
  bool shouldRepaint(_TracingPainter old) =>
      old.demoProgress != demoProgress ||
      old.demoStrokeIndex != demoStrokeIndex ||
      old.mode != mode ||
      old.drawnStrokes.length != drawnStrokes.length ||
      old.currentStroke.length != currentStroke.length ||
      old.glowValue != glowValue ||
      old.pulseValue != pulseValue ||
      old.cursorPos != cursorPos ||
      old.completed != completed ||
      old.penColor != penColor;
}
