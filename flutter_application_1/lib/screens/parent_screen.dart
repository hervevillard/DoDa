import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/progress_manager.dart';
import '../core/language_provider.dart';
import '../theme.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  static const String _pin = '1234';
  final _controller = TextEditingController();
  bool _unlocked = false;
  bool _wrongPin = false;

  void _checkPin() {
    if (_controller.text == _pin) {
      setState(() {
        _unlocked = true;
        _wrongPin = false;
      });
    } else {
      setState(() => _wrongPin = true);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Area'),
        backgroundColor: kColorSurface,
        elevation: 0,
      ),
      body: _unlocked ? _buildDashboard(context) : _buildPinEntry(context),
    );
  }

  Widget _buildPinEntry(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 64, color: kColorPrimary),
            const SizedBox(height: 24),
            Text(
              'Enter Parent PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Default PIN: 1234',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kColorTextLight),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 16),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                errorText: _wrongPin ? 'Incorrect PIN' : null,
              ),
              onSubmitted: (_) => _checkPin(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPin,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final progress = context.watch<ProgressManager>();
    final lang = context.watch<LanguageProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          _StatCard(
            title: 'Total Stars',
            value: '${progress.totalStars}',
            icon: Icons.star,
            color: kColorStar,
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: 'Levels Completed',
            value: '${progress.completedLevels.length}',
            icon: Icons.check_circle,
            color: kColorSuccess,
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: 'Current Language',
            value: lang.languageLabel,
            icon: Icons.language,
            color: kColorSecondary,
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Reset All Progress', style: TextStyle(color: Colors.red)),
            onPressed: () => _confirmReset(context, progress),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, ProgressManager progress) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will erase all stars and completed levels. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await progress.reset();
      if (mounted) Navigator.pop(context);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kColorTextLight),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
