import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, kinyarwanda }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  bool get isEnglish => _language == AppLanguage.english;
  bool get isKinyarwanda => _language == AppLanguage.kinyarwanda;

  String get languageCode => isEnglish ? 'en' : 'rw';
  String get flagAsset => isEnglish
      ? 'assets/images/ui/flag_en.png'
      : 'assets/images/ui/flag_rw.png';

  String get languageLabel => isEnglish ? 'English' : 'Kinyarwanda';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language') ?? 'english';
    _language =
        saved == 'kinyarwanda' ? AppLanguage.kinyarwanda : AppLanguage.english;
    notifyListeners();
  }

  Future<void> toggle() async {
    _language = isEnglish ? AppLanguage.kinyarwanda : AppLanguage.english;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', isEnglish ? 'english' : 'kinyarwanda');
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'language', lang == AppLanguage.english ? 'english' : 'kinyarwanda');
    notifyListeners();
  }

  String localizedText({required String en, required String rw}) {
    return isEnglish ? en : rw;
  }
}
