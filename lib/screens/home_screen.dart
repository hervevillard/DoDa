import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../core/progress_manager.dart';
import '../theme.dart';
import '../widgets/language_toggle.dart';
import '../widgets/mascot.dart';
import '../widgets/star_counter.dart';
import 'progress_map_screen.dart';
import 'parent_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9F0), Color(0xFFFFEDD5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top bar
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const StarCounter(),
                    const LanguageToggle(),
                    IconButton(
                      icon: const Icon(Icons.lock, size: 32, color: kColorTextLight),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ParentScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Mascot(size: 160, expression: MascotExpression.happy),
                    const SizedBox(height: 24),
                    Text(
                      lang.localizedText(en: 'DoDa', rw: 'DoDa'),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: kColorPrimary,
                            letterSpacing: 4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.localizedText(
                        en: 'Let\'s learn together!',
                        rw: 'Twige hamwe!',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: kColorTextLight,
                          ),
                    ),
                    const SizedBox(height: 48),
                    _PlayButton(lang: lang),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final LanguageProvider lang;
  const _PlayButton({required this.lang});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProgressMapScreen()),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
        decoration: BoxDecoration(
          color: kColorPrimary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: kColorPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          lang.localizedText(en: 'Play!', rw: 'Tanga!'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
