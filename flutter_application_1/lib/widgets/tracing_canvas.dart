import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../theme.dart';

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
    with SingleTickerProviderStateMixin {
  final List<Offset> _userPath = [];
  late AnimationController _glowController;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_completed) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    setState(() => _userPath.add(local));
  }

  void _onPanEnd(DragEndDetails _) {
    if (_completed || _userPath.isEmpty) return;
    final accuracy = _calculateAccuracy();
    if (accuracy > 0.3) {
      setState(() => _completed = true);
      widget.onComplete(accuracy);
    }
  }

  double _calculateAccuracy() {
    if (_userPath.isEmpty) return 0;
    // Simple coverage heuristic: unique cells covered in a 10x10 grid
    final covered = <int>{};
    for (final point in _userPath) {
      final cellX = (point.dx / 30).floor().clamp(0, 9);
      final cellY = (point.dy / 30).floor().clamp(0, 9);
      covered.add(cellX * 10 + cellY);
    }
    return (covered.length / 40).clamp(0.0, 1.0);
  }

  void _reset() {
    setState(() {
      _userPath.clear();
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kColorTextLight.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _TracingPainter(
                        letter: widget.letter.letter,
                        userPath: List.from(_userPath),
                        glowValue: _glowController.value,
                        completed: _completed,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!_completed)
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, color: kColorTextLight),
            label: Text(
              'Try again',
              style: TextStyle(color: kColorTextLight),
            ),
          ),
      ],
    );
  }
}

class _TracingPainter extends CustomPainter {
  final String letter;
  final List<Offset> userPath;
  final double glowValue;
  final bool completed;

  _TracingPainter({
    required this.letter,
    required this.userPath,
    required this.glowValue,
    required this.completed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dotted guide letter
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.height * 0.75,
          fontWeight: FontWeight.w900,
          color: Color.lerp(
            const Color(0xFFE0E0E0),
            kColorSecondary.withOpacity(0.4),
            glowValue,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Draw user's traced path
    if (userPath.length > 1) {
      final paint = Paint()
        ..color = completed ? kColorSuccess : kColorPrimary
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(userPath.first.dx, userPath.first.dy);
      for (int i = 1; i < userPath.length; i++) {
        path.lineTo(userPath[i].dx, userPath[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Completion sparkle hint
    if (completed) {
      final sparkPaint = Paint()
        ..color = kColorStar.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        12,
        sparkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TracingPainter old) =>
      old.userPath.length != userPath.length ||
      old.glowValue != glowValue ||
      old.completed != completed;
}
