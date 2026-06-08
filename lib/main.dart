import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/language_provider.dart';
import 'core/progress_manager.dart';
import 'core/audio_player.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final progressManager = ProgressManager();
  await progressManager.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider.value(value: progressManager),
        ChangeNotifierProvider(create: (_) => DodaAudioPlayer()),
      ],
      child: const DodaApp(),
    ),
  );
}

class DodaApp extends StatelessWidget {
  const DodaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoDa',
      debugShowCheckedModeBanner: false,
      theme: dodaTheme,
      home: _AudioUnlockWrapper(child: const HomeScreen()),
    );
  }
}

// Unlocks the audio player on the first user tap (required by browser autoplay policy).
class _AudioUnlockWrapper extends StatefulWidget {
  final Widget child;
  const _AudioUnlockWrapper({required this.child});

  @override
  State<_AudioUnlockWrapper> createState() => _AudioUnlockWrapperState();
}

class _AudioUnlockWrapperState extends State<_AudioUnlockWrapper> {
  bool _unlocked = false;

  void _unlock() {
    if (_unlocked) return;
    _unlocked = true;
    context.read<DodaAudioPlayer>().unlock();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _unlock,
      onPanDown: (_) => _unlock(),
      child: widget.child,
    );
  }
}
