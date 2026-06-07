import 'package:flutter/material.dart';
import '../theme.dart';

enum MascotExpression { happy, celebrating, curious, encouraging }

class Mascot extends StatelessWidget {
  final double size;
  final MascotExpression expression;

  const Mascot({
    super.key,
    required this.size,
    this.expression = MascotExpression.happy,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder mascot — replace with actual gorilla/crowned crane asset
    return CustomPaint(
      size: Size(size, size),
      painter: _MascotPainter(expression: expression),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotExpression expression;
  _MascotPainter({required this.expression});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFFFB347);
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // Ear left
    canvas.drawCircle(Offset(cx - r * 0.8, cy), r * 0.35, bodyPaint);
    // Ear right
    canvas.drawCircle(Offset(cx + r * 0.8, cy), r * 0.35, bodyPaint);

    // Face
    final facePaint = Paint()..color = const Color(0xFFFFD6A5);
    canvas.drawCircle(Offset(cx, cy + r * 0.05), r * 0.7, facePaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF2D3436);
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.15), r * 0.1, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.15), r * 0.1, eyePaint);

    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.18), r * 0.04, shinePaint);
    canvas.drawCircle(Offset(cx + r * 0.31, cy - r * 0.18), r * 0.04, shinePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF2D3436)
      ..strokeWidth = r * 0.06
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    switch (expression) {
      case MascotExpression.happy:
      case MascotExpression.celebrating:
        mouthPath.moveTo(cx - r * 0.25, cy + r * 0.2);
        mouthPath.quadraticBezierTo(cx, cy + r * 0.45, cx + r * 0.25, cy + r * 0.2);
        break;
      case MascotExpression.curious:
        mouthPath.moveTo(cx - r * 0.15, cy + r * 0.25);
        mouthPath.lineTo(cx + r * 0.15, cy + r * 0.25);
        break;
      case MascotExpression.encouraging:
        mouthPath.moveTo(cx - r * 0.2, cy + r * 0.22);
        mouthPath.quadraticBezierTo(cx, cy + r * 0.38, cx + r * 0.2, cy + r * 0.22);
        break;
    }
    canvas.drawPath(mouthPath, mouthPaint);

    // Celebration stars
    if (expression == MascotExpression.celebrating) {
      final starPaint = Paint()..color = kColorStar;
      canvas.drawCircle(Offset(cx + r * 1.1, cy - r * 0.5), r * 0.1, starPaint);
      canvas.drawCircle(Offset(cx - r * 1.1, cy - r * 0.6), r * 0.08, starPaint);
      canvas.drawCircle(Offset(cx + r * 0.9, cy - r * 1.0), r * 0.07, starPaint);
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) => old.expression != expression;
}
