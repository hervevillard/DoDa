import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';
import '../theme.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kColorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kColorTextLight.withOpacity(0.2)),
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
          GestureDetector(
            onTap: lang.isKinyarwanda ? lang.toggle : null,
            child: _LangChip(
              label: 'EN',
              active: lang.isEnglish,
              color: const Color(0xFF003399),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Kinyarwanda — coming soon',
            triggerMode: TooltipTriggerMode.tap,
            child: _LangChip(
              label: 'RW',
              active: false,
              color: const Color(0xFF20603D),
              disabled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final bool disabled;

  const _LangChip({
    required this.label,
    required this.active,
    required this.color,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: disabled
              ? kColorTextLight.withOpacity(0.35)
              : active
                  ? Colors.white
                  : kColorTextLight,
        ),
      ),
    );
  }
}
