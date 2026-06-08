import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Full-screen African savanna background gradient.
class AfricanBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const AfricanBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ??
              [
                const Color(0xFFFFB347), // sunrise amber top
                const Color(0xFFFF7F50), // coral mid
                const Color(0xFF2D8C5E), // savanna green base
              ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Warm parchment background for activity screens.
class ParchmentBackground extends StatelessWidget {
  final Widget child;
  const ParchmentBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF4E7), Color(0xFFF5E6CC)],
        ),
      ),
      child: child,
    );
  }
}

/// A decorative sun in the top-right corner.
class DecorativeSun extends StatelessWidget {
  final double size;
  const DecorativeSun({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SunPainter()),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.3;

    // Rays
    final rayPaint = Paint()
      ..color = kColorAccent.withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final innerR = r + 6;
      final outerR = r + 20 + (i.isEven ? 8 : 0);
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        rayPaint,
      );
    }

    // Glow halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          kColorAccent.withOpacity(0.4),
          kColorAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.8));
    canvas.drawCircle(Offset(cx, cy), r * 1.8, haloPaint);

    // Sun disc
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFF176), kColorAccent],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, sunPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Kente-pattern horizontal divider strip.
class KenteDivider extends StatelessWidget {
  final double height;
  const KenteDivider({super.key, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _KentePainter(),
        size: Size(double.infinity, height),
      ),
    );
  }
}

class _KentePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [kColorKente1, kColorKente3, kColorKente2, kColorKente3];
    final blockW = size.height * 1.2;
    final count = (size.width / blockW).ceil() + 1;
    for (int i = 0; i < count; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawRect(
        Rect.fromLTWH(i * blockW, 0, blockW, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Decorative Adinkra-style circle badge used on level nodes.
class AdinkraBadge extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;

  const AdinkraBadge({
    super.key,
    required this.child,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: kColorAccent, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: kColorAccent.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

/// Tracing color options for the child to choose from.
const kTracingColors = [
  Color(0xFFE8611A), // terracotta
  Color(0xFF2D8C5E), // green
  Color(0xFF1B2A4A), // navy
  Color(0xFFD64E12), // red
  Color(0xFF8B5E3C), // brown
  Color(0xFF6A0DAD), // purple
];
