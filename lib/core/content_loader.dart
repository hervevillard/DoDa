import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';

class ContentLoader {
  static List<LetterModel>? _lettersEn;
  static List<LetterModel>? _lettersRw;
  static List<LetterModel>? _numbers;
  static List<WordModel>? _words;

  // Always loads English — bilingual letter tracing not yet supported.
  static Future<List<LetterModel>> loadLetters(String languageCode) async {
    _lettersEn ??= await _loadLettersFromAsset('assets/data/letters_en.json');
    return _lettersEn!;
  }

  static Future<List<LetterModel>> loadNumbers() async {
    _numbers ??= await _loadLettersFromAsset('assets/data/numbers.json');
    return _numbers!;
  }

  static Future<List<WordModel>> loadWords() async {
    _words ??= await _loadWordsFromAsset('assets/data/words.json');
    return _words!;
  }

  static Future<List<LetterModel>> _loadLettersFromAsset(String path) async {
    final json = await rootBundle.loadString(path);
    final list = jsonDecode(json) as List;
    return list.map((e) => LetterModel.fromJson(e)).toList();
  }

  static Future<List<WordModel>> _loadWordsFromAsset(String path) async {
    final json = await rootBundle.loadString(path);
    final list = jsonDecode(json) as List;
    return list.map((e) => WordModel.fromJson(e)).toList();
  }
}
