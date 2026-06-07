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
        Provider(create: (_) => DodaAudioPlayer()),
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
      home: const HomeScreen(),
    );
  }
}
