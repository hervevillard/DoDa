import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/progress_manager.dart';
import '../theme.dart';

class StarCounter extends StatelessWidget {
  const StarCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final stars = context.watch<ProgressManager>().totalStars;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kColorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kColorStar.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: kColorStar, size: 22),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$stars',
              key: ValueKey(stars),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kColorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
