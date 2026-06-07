import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressManager extends ChangeNotifier {
  int _totalStars = 0;
  final Set<String> _completedLevels = {};
  final Map<String, int> _levelStars = {};

  int get totalStars => _totalStars;
  Set<String> get completedLevels => Set.unmodifiable(_completedLevels);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _totalStars = prefs.getInt('total_stars') ?? 0;

    final completed = prefs.getStringList('completed_levels') ?? [];
    _completedLevels.addAll(completed);

    for (final levelId in completed) {
      _levelStars[levelId] = prefs.getInt('stars_$levelId') ?? 0;
    }
    notifyListeners();
  }

  bool isLevelUnlocked(String levelId, List<String> prerequisiteIds) {
    if (prerequisiteIds.isEmpty) return true;
    return prerequisiteIds.every((id) => _completedLevels.contains(id));
  }

  bool isLevelCompleted(String levelId) => _completedLevels.contains(levelId);

  int starsForLevel(String levelId) => _levelStars[levelId] ?? 0;

  Future<void> completeLevel(String levelId, int stars) async {
    final wasCompleted = _completedLevels.contains(levelId);
    _completedLevels.add(levelId);

    final previousStars = _levelStars[levelId] ?? 0;
    final newStars = stars.clamp(0, 3);
    _levelStars[levelId] = newStars;

    if (!wasCompleted) {
      _totalStars += newStars;
    } else if (newStars > previousStars) {
      _totalStars += newStars - previousStars;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_stars', _totalStars);
    await prefs.setStringList(
        'completed_levels', _completedLevels.toList());
    await prefs.setInt('stars_$levelId', newStars);

    notifyListeners();
  }

  Future<void> reset() async {
    _totalStars = 0;
    _completedLevels.clear();
    _levelStars.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
